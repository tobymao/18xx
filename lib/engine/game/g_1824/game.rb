# frozen_string_literal: true

require_relative '../g_1837/game'
require_relative 'meta'
require_relative '../base'
require_relative '../g_1837/round/exchange'
require_relative 'round/operating'
require_relative 'company'
require_relative 'depot'
require_relative 'entities'
require_relative 'map'
require_relative 'market'
require_relative 'phases'
require_relative 'trains'

module Engine
  module Game
    module G1824
      class Game < G1837::Game
        include_meta(G1824::Meta)
        include G1824::Entities
        include G1824::Map
        include G1824::Market
        include G1824::Phases
        include G1824::Trains

        CORPORATION_CLASS = G1824::Corporation
        DEPOT_CLASS = G1824::Depot

        attr_accessor :two_train_bought, :forced_mountain_railway_exchange, :player_debts, :current_stack,
                      :kk_token_choice_player

        CURRENCY_FORMAT_STR = '%sG'

        # Rule III.3 standard game, X.2 Cislethania 2p, XI.2 Cislethania 3p
        STARTING_CASH = { 3 => 820, 4 => 680, 5 => 560, 6 => 460 }.freeze
        # Note! 700 for 3 players is a correction. The rule book has incorrect 680.
        # Ref: https://boardgamegeek.com/thread/2342047/3-player-cisleithania-starting-treasury-error
        CASH_CISLEITHANIA = { 2 => 830, 3 => 700 }.freeze

        # Rule III.4 standard game, X.1 Cislethania 2p, XI.1 Cislethania 3p
        BANK_CASH = 12_000
        BANK_CASH_CISLEITHANIA = { 2 => 4000, 3 => 9000 }.freeze

        # Rule VI.7 standard game, X.2 Cislethania 2p, XI.2 Cislethania 3p
        CERT_LIMIT = { 3 => 21, 4 => 16, 5 => 13, 6 => 11 }.freeze
        CERT_LIMIT_CISLEITHANIA = { 2 => 14, 3 => 16 }.freeze

        # Rule VII.13, bullet 3
        DISCARDED_TRAINS = :remove

        # SELL_BUY_ORDER, same as 1837 (:sell_buy), see Rule VI.1 bullet 4
        # SELL_AFTER, same as 1837 (:operate), see Rule VI.8
        # SELL_MOVEMENT, same as 1837 (:down_block), see Rule VIII.3

        MUST_SELL_IN_BLOCKS = false

        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
        EBUY_FROM_OTHERS = :always
        EBUY_SELL_MORE_THAN_NEEDED = true
        EBUY_SELL_MORE_THAN_NEEDED_SETS_PURCHASE_MIN = true
        MUST_BUY_TRAIN = :always

        # Rule IX. This differ from 1837 as players in 1824 do not go bankrupt.
        GAME_END_CHECK = { bank: :full_or }.freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'buy_across' => ['Buy Across', 'Trains can be bought between companies'],
          'close_mountain_railways' => ['Mountain Railways Close', 'Any still open Montain railways are exchanged or closed'],
          'sd_formation' => ['SD formation', 'SD forms at the end of the OR'],
          'exchange_coal_companies' => ['Coal Companies Exchange', 'All remaining coal companies are exchanged'],
          'ug_formation' => ['UG formation', 'UG forms at the end of the OR'],
          'kk_formation' => ['k&k formation', 'KK forms at the end of the OR'],
          'close_construction_railways' => ['Close Construction Railways', 'All construction minors are closed'],
          'vienna_tokened' => ['Vienna tokened',
                               'When Vienna is upgraded to Brown the last token of the bond railway is placed there'],
        ).freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'may_exchange_coal_railways' => ['Coal Railway exchange', 'May exchange Coal Railways during SR'],
          'may_exchange_mountain_railways' => ['Mountain Railway exchange', 'May exchange Mountain Railways during SR']
        ).freeze

        MOUNTAIN_RAILWAY_NAMES = {
          1 => 'Semmeringbahn',
          2 => 'Kastbahn',
          3 => 'Brennerbahn',
          4 => 'Arlbergbahn',
          5 => 'Karawankenbahn',
          6 => 'Wocheinerbahn',
        }.freeze

        # Standard game has 4 mine hexes, Cislethania has 3
        MINE_HEX_NAMES = %w[C6 A12 A22 H25].freeze
        MINE_HEX_NAMES_CISLEITHANIA = %w[C6 A12 A22].freeze

        # Used for Bukowina bonus on the Cisleithania map
        # Bukowina bonus is for a route that included Prag/Vienna and one of the 3 green hexes in the East
        BUKOWINA_SOURCES = %w[E12 B9].freeze
        BUKOWINA_TARGETS = %w[D25 E24 E26].freeze

        ASSIGNMENT_TOKENS = {
          'coal' => '/icons/1837/coalcar.svg',
        }.freeze

        # Modified from 1837 as 1824 does not have single shares in Pre-staatsbahn
        def company_header(company)
          return stackify(company, 'COAL COMPANY') if company.color == :black
          return stackify(company, 'MOUNTAIN RAILWAY') if company.color == :gray

          stackify(company, 'MINOR COMPANY')
        end

        def init_optional_rules(optional_rules)
          opt_rules = super

          # 2 player variant always use the Cisleithania map
          opt_rules << :cisleithania if two_player? && !opt_rules.include?(:cisleithania)

          # Good Time variant is not applicable if Cisleithania is used
          opt_rules -= [:goods_time] if opt_rules.include?(:cisleithania)

          opt_rules
        end

        def init_bank
          return super unless option_cisleithania

          Engine::Bank.new(BANK_CASH_CISLEITHANIA[@players.size], log: @log)
        end

        def init_starting_cash(players, bank)
          return super unless option_cisleithania

          players.each do |player|
            bank.spend(CASH_CISLEITHANIA[@players.size], player)
          end
        end

        def init_share_pool
          G1824::SharePool.new(self)
        end

        # Need to handle special valuation of some minors, and also handle debt
        def player_value(player)
          shares_valuation = player.shares.select { |s| s.corporation.ipoed }.sum { |s| player_share_valuation(s) }
          player.cash + shares_valuation + player.companies.sum(&:value) - @player_debts[player]
        end

        def player_share_valuation(share)
          corp = share.corporation

          # Coal railways are worth bought price (which is actually par price for the associated regional)
          # but I use this 1824 attribute Corporation#coal_price as it is needed before regional is IPOed.
          return corp.coal_price if coal_railway?(corp)

          # The share price seems to be 120G for all other minors, but SD1/UG1/KK1 are worth 240G, as
          # they correspond to the 20% share of the national.
          return share.price * 2 if corp.id.end_with?('1')

          share.price
        end

        def game_cert_limit
          return super unless option_cisleithania

          CERT_LIMIT_CISLEITHANIA[@players.size]
        end

        # Rule VI.78, bullet 4: Cannot buy if holding 60% or more
        # but can exceed via exchanges
        def can_hold_above_corp_limit?(_entity)
          true
        end

        def can_buy_presidents_share_directly_from_market?(corporation)
          # Rule X.4, bullet 3, sub-bullet 6: 20% is just a double share
          return true if two_player? && bond_railway?(corporation)

          super
        end

        # Modified 1837 version as the number of trains vary between player count and variant
        def init_train_handler
          train_count_map = num_trains_map
          trains = game_trains.flat_map do |train|
            t = train
            t = adjust_events_for_two_players(t) if two_player?
            Array.new(train_count_map[t[:name]]) do |index|
              Train.new(**t, index: index)
            end
          end

          G1824::Depot.new(trains, self)
        end

        def num_trains_map
          if two_player?
            self.class::TRAIN_COUNT_2P_CISLETHANIA
          elsif @players.size == 3 && option_cisleithania
            self.class::TRAIN_COUNT_3P_CISLETHANIA
          else
            self.class::TRAIN_COUNT_STANDARD
          end
        end

        def game_corporations
          corporations = CORPORATIONS.dup

          if option_cisleithania && !two_player?
            # Rule XI.1: Move home location for UG1, and reserve only 20% share of UG
            corporations.map! do |m|
              case m['sym']
              when 'UG1'
                m['coordinates'] = 'G12'
                m['city'] = 0
              when 'UG'
                m['ipo_shares'] = [10, 10, 10, 10, 10, 10, 10, 10]
                m['reserved_shares'] = [20]
              end

              m
            end
          end

          corporations
        end

        def init_corporations(stock_market)
          all = super

          if option_cisleithania && two_player?
            # Rule X.1: Remove Pre-Staatsbahns UG1 and UG2, Regionals BH and SB, Coal mine SPB
            all.select { |c| %w[UG UG1 UG2 BH SB SPB].include?(c.id) }.each(&:close!)
          end

          if option_cisleithania && !two_player?
            # Rule XI.1: Remove Pre-Staatsbahn UG2, Regionals BH and SB, Coal mine SPB
            all.select { |c| %w[UG2 BH SB SPB].include?(c.id) }.each(&:close!)
          end

          all
        end

        def init_companies(players)
          companies = COMPANIES.dup

          mountain_railway_count =
            case players.size
            when 2
              2
            when 3
              option_cisleithania ? 3 : 4
            when 4, 5
              6
            when 6
              4
            end
          mountain_railway_count.times { |index| companies << mountain_railway_definition(index) }

          if option_cisleithania
            # Rule X.1/XI.1: Remove Coal mine SPB, Pre-Staatsbahn UG2, and - if 2 players - UG1
            removed_companies = players.size == 2 ? %w[SPB UG2 UG1] : %w[SPB UG2]
            companies.reject! { |m| removed_companies.include?(m[:sym]) }
          end

          used_companies = companies.map { |company| G1824::Company.new(**company) }

          # Rule X.3 Setup, need to do some modifications of companies for two players
          # and need to do it before trains which also are affected
          @close_construction_company_when_first_5_sold = false
          setup_companies_for_two_players(used_companies) if two_player?

          used_companies
        end

        def init_tiles
          tiles = TILES.dup

          if option_goods_time
            # Goods Time increase count for some town related tiles
            tiles['3'] += 3
            tiles['4'] += 3
            tiles['56'] += 1
            tiles['58'] += 3
            tiles['87'] += 2
            tiles['630'] += 1
            tiles['631'] += 1

            # New tile for Goods Time variant
            tiles['204'] = 3
          end

          # Remove all Budapest specific tiles as Budapest is an offboard city in Cisleithania
          %w[126 490 495 498].each { |name| tiles.delete(name) } if option_cisleithania

          tiles.flat_map do |name, val|
            init_tile(name, val)
          end
        end

        def option_cisleithania
          two_player? || @optional_rules&.include?(:cisleithania)
        end

        def option_goods_time
          @optional_rules&.include?(:goods_time)
        end

        def location_name(coord)
          return super unless option_cisleithania

          unless @location_names
            @location_names = LOCATION_NAMES.dup
            @location_names['F25'] = 'Kronstadt'
            @location_names['G12'] = 'Budapest'
            @location_names['I10'] = 'Bosnien'
          end
          @location_names[coord]
        end

        def optional_hexes
          option_cisleithania ? cisleithania_map : base_map
        end

        def sold_shares_destination(_entity)
          # Rule VI.8 - 1824 has no bank pool
          return :corporation unless two_player?

          # Rule X.4, bullet 2 - 2 player 1824 has a bank pool
          :bank
        end

        # 1824 differ from 1837 as it allows any legal single town upgrade to green (duble towns have no green tiles)
        def yellow_town_tile_upgrades_to?(from, to)
          # honors pre-existing track?
          from.paths_are_subset_of?(to.paths)
        end

        # Similar to 1837
        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
              sr_round_finished
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_exchange_round(Round::Operating)
            when G1837::Round::Exchange
              if @round_after_exchange == Engine::Round::Stock
                new_stock_round
              else
                new_operating_round(@round.round_num)
              end
            when Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_exchange_round(Round::Operating, @round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                new_exchange_round(Engine::Round::Stock)
              end
            when init_round.class
              init_round_finished
              reorder_players
              new_stock_round
            end
          @round
        end

        def init_round
          @log << '-- First Stock Round --'
          @log << 'Player order is reversed during the first turn'
          G1824::Round::FirstStock.new(self, [
            G1824::Step::BuySellParSharesFirstSr,
          ])
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            G1824::Step::DiscardTrain,
            G1824::Step::KkTokenChoice, # In case train export triggers KK formation
            G1824::Step::ForcedMountainRailwayExchange, # In case train export after OR set triggers exchage
            G1824::Step::BuySellParExchangeShares,
          ])
        end

        def operating_round(round_num)
          G1824::Round::Operating.new(self, [
            G1837::Step::Bankrupt,
            G1824::Step::KkTokenChoice,
            G1824::Step::DiscardTrain,
            G1824::Step::BondToken,
            Engine::Step::SpecialTrack,
            G1824::Step::Track,
            G1824::Step::Token,
            Engine::Step::Route,
            G1824::Step::Dividend,
            G1824::Step::BuyTrain,
          ], round_num: round_num)
        end

        def new_exchange_round(next_round, round_num = 1)
          @round_after_exchange = next_round
          exchange_round(round_num)
        end

        def exchange_round(round_num)
          G1837::Round::Exchange.new(self, [
            G1837::Step::DiscardTrain,
            G1837::Step::CoalExchange,
          ], round_num: round_num)
        end

        def or_round_finished
          potentially_form_nationals
        end

        def sr_round_finished
          # Rule VII.12, bullet 7: Debts increase by 50%
          add_interest_player_loans!
        end

        def or_set_finished
          depot.export!
          potentially_form_nationals
        end

        # 1824 does not have a par chart, but 1837 do, so disable it.
        def par_chart; end

        # 1824 does not need this (as it does not use par_chart), but 1837 do, so make it noop.
        def set_par(_corporation, _share_price, _slot); end

        def init_stock_market
          StockMarket.new(game_market, self.class::CERT_LIMIT_TYPES)
        end

        def setup
          # To keep track of when 1st two train bought, for g-trains
          # TODO: Check if this is needed?
          @two_train_bought = false

          # When 1st 4-train is bought any remaining MRs will be exchanged
          @forced_mountain_railway_exchange = []

          # Initialize the player debts, if player have to take an emergency loan
          @player_debts = Hash.new { |h, k| h[k] = 0 }

          super
          setup_regionals
          @sd_to_form = false
          @ug_to_form = false
          @kk_to_form = false

          # Used in two-player for extra tokening when last 4 sold (or last 5, if were exported)
          @train_based_bond_token_used = false
          @corporation_to_put_train_based_bond_token = nil

          # Used in two-player for extra tokening when Wien upgraded to brown
          @upgrade_based_bond_token_used = false
          @corporation_to_put_upgrade_based_bond_token = nil
        end

        def setup_mines
          mine_hex_names = option_cisleithania ? MINE_HEX_NAMES_CISLEITHANIA : MINE_HEX_NAMES
          mine_hex_names.each do |hex_id|
            hex_by_id(hex_id).assign!(:coal)
          end
        end

        def setup_nationals
          # Rule IV.4.4
          market_row = stock_market.market[0]
          share_price = market_row.find { |sp| sp.price == 120 }
          %w[SD UG KK].each do |c|
            national = corporation_by_id(c)

            # Rule X.1, bullet 3: Do not use UG in two player game (it is closed)
            next if national.closed?

            stock_market.set_par(national, share_price)
            national.ipoed = true
          end
        end

        def setup_regionals
          @corporations.each do |corporation|
            next if corporation.closed?
            next unless regional?(corporation)

            if corporation.id == 'BH'
              # BH is a regional without association to coal railway
              corporation.remove_reserve_for_all_shares!
            else
              # Remaining regionals are OPOed by buying a coal railway
              # and should have shares buyable but presidency reserved.
              # Note if coal railway not sold, the regional is similar to BH.
              # That case is handled in the first stock round.
              corporation.should_not_float_until_exchange!
            end
          end
        end

        def ipo_name(_entity = nil)
          'Bank'
        end

        def ipo_reserved_name(_entity = nil)
          'Reserved'
        end

        def sd_minors
          @sd_minors ||= %w[SD1 SD2 SD3].map { |id| corporation_by_id(id) }.reject(&:closed?)
        end

        def kk_minors
          @kk_minors ||= %w[KK1 KK2].map { |id| corporation_by_id(id) }.reject(&:closed?)
        end

        def ug_minors
          @ug_minors ||= %w[UG1 UG2].map { |id| corporation_by_id(id) }.reject(&:closed?)
        end

        def coal_minors
          @coal_minors ||= %w[EPP EOD MLB SPB].map { |id| corporation_by_id(id) }.reject(&:closed?)
        end

        def timeline
          @timeline ||= ['At the end of each OR set, the cheapest non-g train in bank is exported.'].freeze
        end

        # In 1824 the close of MRs means they will be exchanged (if possible)
        def event_close_mountain_railways!
          @log << "-- Event: #{EVENTS_TEXT['close_mountain_railways'][1]} --"
          @forced_mountain_railway_exchange = @companies.select { |c| mountain_railway?(c) && !c.closed? }
        end

        # In 1824 the SD formation is mandatory, and happens at end of OR
        def event_sd_formation!
          @log << "-- Event: #{EVENTS_TEXT['sd_formation'][1]} --"
          @sd_to_form = true
        end

        # In 1824 the UG formation is mandatory, and happens at end of OR
        def event_ug_formation!
          @log << "-- Event: #{EVENTS_TEXT['ug_formation'][1]} --"
          @ug_to_form = true
        end

        # In 1824 the KK formation is mandatory, and happens at end of OR
        def event_kk_formation!
          @log << "-- Event: #{EVENTS_TEXT['kk_formation'][1]} --"
          @kk_to_form = true
        end

        def event_close_construction_railways!
          @log << "-- Event: #{EVENTS_TEXT['close_construction_railways'][1]} --"
          @corporations.each do |c|
            next unless construction_railway?(c)

            @log << "#{c.name} closes without compensation"
            c.tokens.first.swap!(blocking_token, check_tokenable: false) if c.color == :black
            close_corporation(c, quiet: true)
            graph.clear_graph_for(c)
          end
        end

        def event_vienna_tokened!
          @log << "-- Event: #{EVENTS_TEXT['vienna_tokened'][1]} --"
          @token_vienna_when_brown = true
        end

        def status_str(entity)
          if bond_railway?(entity)
            'Bond Railway - pay stock value each OR'
          elsif construction_railway?(entity)
            'Construction Railway - only build tracks'
          elsif coal_railway?(entity)
            'Coal Railway - may only own g trains'
          elsif pre_staatsbahn?(entity)
            'Pre-Staatsbahn'
          elsif staatsbahn?(entity)
            'Staatsbahn'
          elsif regional?(entity)
            str = 'Regional Railway'
            if (coal = associated_coal_railway(entity)) && !coal.closed?
              str += " - Presidency #{coal.name}"
            end
            str
          end
        end

        def goods_train?(train_name)
          train_name.end_with?('g')
        end

        def mountain_railway_exchangable?
          @phase.status.include?('may_exchange_mountain_railways')
        end

        def get_associated_regional_railway(minor)
          exchange_ability = minor.all_abilities.find { |abil| abil.type == :exchange }
          corporation_by_id(exchange_ability.corporations.first)
        end

        def coal_railway_exchangable?
          @phase.status.include?('may_exchange_coal_railways')
        end

        def exchange_entities
          @companies.reject(&:closed?)
        end

        def mountain_railway?(entity)
          entity.company? && entity.meta[:type] == :mountain_railway
        end

        def bond_railway?(entity)
          entity.type == :bond_railway
        end

        def construction_railway?(entity)
          entity.type == :construction_railway
        end

        def coal_railway?(entity)
          entity.color == :black && entity.type == :minor
        end

        def pre_staatsbahn?(entity)
          entity.color != :black && entity.type == :minor
        end

        def regional?(entity)
          entity.type == :major
        end

        def staatsbahn?(entity)
          entity.type == :national
        end

        def reserved_regional?(entity)
          return false unless regional?(entity)

          entity.floatable
        end

        def bond_railway
          @bond_railway ||= @corporations.find { |c| bond_railway?(c) }
        end

        def kk
          @kk ||= corporation_by_id('KK')
        end

        def buyable?(entity)
          # TODO: Is this OK? Do we still need buyable?
          return true if entity.nil?

          entity.all_abilities.none? { |a| a.type == :no_buy }
        end

        def exchangable_for_mountain_railway?(player, corporation)
          corporation.type == :major && @companies.find { |c| mountain_railway?(c) && c.owned_by?(player) }
        end

        # Rule X.4, should be able to sell bundles with presidency share
        def bundles_for_corporation(share_holder, corporation, shares: nil)
          return super unless two_player?
          return super unless bond_railway?(corporation)

          shares = (shares || share_holder.shares_of(corporation))

          bundles = (1..shares.size).flat_map do |n|
            shares.combination(n).to_a.map { |ss| Engine::ShareBundle.new(ss) }
          end

          bundles = bundles.uniq do |b|
            [b.shares.count { |s| s.percent == 10 },
             b.presidents_share ? 1 : 0,
             b.shares.find(&:last_cert) ? 1 : 0]
          end

          bundles.sort_by(&:percent)
        end

        def corporation_available?(entity)
          buyable?(entity)
        end

        def entity_can_use_company?(_entity, _company)
          # Return false here so that Exchange abilities does not appear in GUI
          false
        end

        def sorted_corporations
          sorted_corporations = super
          return sorted_corporations unless @turn == 1

          # Remove unbuyable stuff in SR 1 to reduce information
          sorted_corporations.select { |c| buyable?(c) }
        end

        # TODO: This is a work around to avoid bond railway to appear twice in Entities view.
        # That is as bond railway is both bank owned and in receivership.
        # See https://github.com/tobymao/18xx/issues/11929
        def receivership_corporations
          []
        end

        def operating_order
          minors, majors = @corporations.select(&:floated?).partition { |c| c.type == :minor || c.type == :construction_railway }
          minors + majors.sort
        end

        def exchange_order
          coal_minor_exchange_order
        end

        # Changed log text compared to 1837
        def exchange_coal_minor(minor)
          target = exchange_target(minor)
          @log << "#{minor.id} exchanged for the president's share of #{target.id}"
          merge_minor!(minor, target)
        end

        # Slightly modified compared to 1837
        def minor_initial_cash(minor, price)
          case minor.id
          when 'KK1', 'SD1', 'UG1'
            240
          when 'KK2', 'SD2', 'SD3', 'UG2'
            120
          else
            minor.coal_price = price if coal_railway?(minor)
            price
          end
        end

        # This is modified quite a lot compared to 1837
        def after_buy_company(player, company, price)
          return if mountain_railway?(company)

          id = company.id

          abilities(company, :shares) do |ability|
            share = ability.shares.first
            @share_pool.buy_shares(player, share, exchange: :free)
            float_minor!(share.corporation, price) if share.president
          end

          company.close!

          minor = corporation_by_id(id)

          # Need to handle construction railways when two player variant
          if two_player? && company.stack == 1
            if pre_staatsbahn?(minor)
              create_construction_railway_from_bought_pre_staatsbahn(company, minor)
            else
              create_construction_railways_from_coal_mine(company, minor)
            end

            company.stack = nil
            return
          end

          company.stack = nil
          return unless coal_railway?(minor)

          # Rule IV.2, bullet 8: Coal Railways start with a g train bought from the depot
          g_train = depot.upcoming.select { |t| goods_train?(t.name) }.shift
          log << "#{id} buys a #{g_train.name} train from the depot for #{format_currency(g_train.price)}"
          buy_train(minor, g_train, g_train.price)

          regional_railway = get_associated_regional_railway(minor)
          regional_railway.ipoed = true
          share_price = stock_market.par_prices.find { |s| s.price == price / 2 }
          stock_market.set_par(regional_railway, share_price)
          association = "the associated Regional Railway of #{id}"
          log << "#{regional_railway.name} (#{association}) pars at #{format_currency(share_price.price)}."
        end

        # This 1837 version with some tweeks
        def merge_minor!(minor, corporation, allow_president_change: true)
          # 1824 ADD BEGIN
          # Make it a proper major/national (eg. president is now possible?)
          corporation.prepare_merge!
          # Note - do not use floated? here as this might change floated status.
          floated = corporation.floated
          # 1824 ADD END

          @log << "#{minor.name} merges into #{corporation.name}"

          # This part has been simplified in 1824, as a minor can only have one owner
          # and if its a lesser pre-staatsbahn it should correspond to a 10% share in
          # the mergee, otherwise 20%.
          minor.share_holders.each do |sh, _|
            num_shares = sh.shares_of(minor).size
            next if num_shares.zero?

            num_shares = 2 if coal_minor?(minor) || minor.id.end_with?('1')

            share = corporation.shares.find { |s| !s.buyable && s.percent == num_shares * 10 }
            @log << "#{sh.name} receives #{num_shares} share#{num_shares > 1 ? 's' : ''} of #{corporation.name}"
            share.buyable = true

            # 1824 fix. We explicitly set allow_president_change to true here as we otherwise get a strange
            # behavior when presidency decided for nationals. Might need revisiting.
            @share_pool.transfer_shares(share.to_bundle, sh, allow_president_change: true)
            if @round.respond_to?(:non_paying_shares) && operated_this_round?(minor)
              @round.non_paying_shares[sh][corporation] += num_shares
            end
          end

          if minor.cash.positive?
            @log << "#{corporation.name} receives #{format_currency(minor.cash)}"
            minor.spend(minor.cash, corporation)
          end

          unless minor.trains.empty?
            trains_str = "#{minor.trains.map(&:name).join(', ')} train#{minor.trains.size > 1 ? 's' : ''}"
            if @round.merged_trains[corporation].empty? && corporation.trains.size >= train_limit(corporation)
              @log << "Discarding #{minor.name}'s #{trains_str} because #{corporation.name} has reached its train limit"
              minor.trains.each { |t| @depot.reclaim_train(t) }
            else
              @log << "#{corporation.name} receives #{trains_str}"
              @round.merged_trains[corporation].concat(minor.trains)
              minor.trains.dup.each { |t| buy_train(corporation, t, :free) }
            end
          end

          if coal_minor?(minor)
            minor.tokens.first.swap!(blocking_token, check_tokenable: false)
          else
            token = minor.tokens.first
            new_token = Token.new(corporation)
            corporation.tokens << new_token
            # 1824 Removed special case with L2, L8 as does not exist
            token.swap!(new_token, check_tokenable: false)
            @log << "#{corporation.name} receives token (#{new_token.used ? new_token.city.hex.id : 'charter'})"
          end

          close_corporation(minor, quiet: true)
          graph.clear_graph_for(corporation)

          # 1824 ADD BEGIN
          float_corporation(corporation) if regional?(corporation) && corporation.floatable && floated != corporation.floated?
          # 1824 ADD END
        end

        def place_home_token(corporation)
          # When Staatsbahn is formed it uses existing Pre-Staatsbahn so no new token is placed
          return if staatsbahn?(corporation)

          super
        end

        def associated_coal_railway(regional_railway)
          coal_railway =
            case regional_railway.name
            when 'BK'
              'EPP'
            when 'MS'
              'EOD'
            when 'CL'
              'MLB'
            when 'SB'
              'SPB'
            end
          corporation_by_id(coal_railway)
        end

        def associated_regional_name(coal_railway)
          case coal_railway.sym
          when 'EPP'
            'BK'
          when 'EOD'
            'MS'
          when 'MLB'
            'CL'
          when 'SPB'
            'SB'
          end
        end

        def revenue_for(route, stops)
          # Rule VII.9, bullet 6: Cannot visit the same revenue center twice (see correction in info)
          all_stops = stops.map(&:hex)
          raise GameError, 'Route cannot visit same revenue center twice' if all_stops.size != all_stops.uniq.size

          super + bukowina_bonus_amount(route, stops)
        end

        def revenue_str(route)
          str = super
          str += ' + Bukowina' if bukowina_bonus_amount(route, route.stops).positive?
          str
        end

        def float_str(entity)
          return super unless entity.corporation

          case entity.id
          when 'BK', 'MS', 'CL', 'SB'
            needed = entity.percent_to_float
            if needed.positive?
              need_exchange = entity.floatable ? '' : ' + exchange '
              "#{entity.percent_to_float}%#{need_exchange} to float"
            else
              'Exchange to float'
            end
          when 'UG'
            'UG1 exchange to float'
          when 'KK'
            'KK1 exchange to float'
          when 'SD'
            'SD1 exchange to float'
          else
            super
          end
        end

        # Simplified version compared to 1837
        def float_minor!(minor, price)
          cash = minor_initial_cash(minor, price)
          @bank.spend(cash, minor)
          @log << "#{minor.name} receives #{format_currency(cash)}"
          place_home_token(minor)
          if minor.corporation?
            minor.floated = true
          else
            minor.float!
          end
        end

        def take_player_loan(player, loan)
          # Give the player the money. The money for loans is outside money, doesnt count towards the normal bank money.
          player.cash += loan

          # Add interest to the loan, must atleast pay 150% of the loaned value
          loan_interest = player_loan_interest(loan)
          @player_debts[player] += loan + loan_interest

          @log << "#{player.name} takes a loan of #{format_currency(loan)}. " \
                  "Interest #{loan_interest} added to debt."
        end

        def take_loan(player, amount)
          loan_amount = (amount.to_f * 1.5).ceil

          increase_debt(player, loan_amount)

          @log << "#{player.name} takes a loan of #{format_currency(amount)}. " \
                  "The player debt is increased by #{format_currency(loan_amount * 2)}."

          @bank.spend(loan_amount, player)
        end

        def add_interest_player_loans!
          @player_debts.each do |player, loan|
            next unless loan.positive?

            interest = player_loan_interest(loan)
            new_loan = loan + interest
            @player_debts[player] = new_loan
            @log << "#{player.name} increases their loan by 50% (#{format_currency(interest)}) to "\
                    "#{format_currency(new_loan)}."
          end
        end

        # Pay full or partial of the player loan. The money from loans is
        # outside money, doesnt count towards the normal bank money.
        def payoff_player_loan(player, payoff_amount: nil)
          loan_balance = @player_debts[player]
          payoff_amount = player.cash if !payoff_amount || payoff_amount > player.cash
          payoff_amount = [payoff_amount, loan_balance].min

          @player_debts[player] -= payoff_amount
          player.cash -= payoff_amount

          @log <<
            if payoff_amount == loan_balance
              "#{player.name} pays off their loan of #{format_currency(loan_balance)}."
            else
              "#{player.name} decreases their loan by #{format_currency(payoff_amount)} "\
                "(#{format_currency(@player_debts[player])})."
            end
        end

        def player_debt(player)
          @player_debts[player] || 0
        end

        def set_last_train_buyer(buyer, train)
          return unless two_player?
          return if @train_based_bond_token_used

          @corporation_to_put_train_based_bond_token = buyer
          @log << "Last #{train.name} bought by #{buyer.name} which means "\
                  "#{buyer.name} (#{buyer.owner.name}) gets to put a #{bond_railway.name} "\
                  'token anywhere where the slot it is free.'
        end

        def extra_token_entity
          return unless two_player?
          return if @train_based_bond_token_used

          @corporation_to_put_train_based_bond_token
        end

        def clear_extra_token_entity
          @train_based_bond_token_used = true
          @corporation_to_put_train_based_bond_token = nil
        end

        def notify_vienna_can_be_tokened_by_bond_railway(entity)
          return unless two_player?

          @log << "Vienna upgraded to brown by #{entity.name} which means "\
                  "#{entity.name} (#{entity.owner.name}) gets to put a #{bond_railway.name} token in Vienna."
          @corporation_to_put_upgrade_based_bond_token = entity
        end

        def vienna_token_entity
          return unless two_player?
          return if @upgrade_based_bond_token_used

          @corporation_to_put_upgrade_based_bond_token
        end

        def clear_vienna_token_entity
          @upgrade_based_bond_token_used = true
          @corporation_to_put_upgrade_based_bond_token = nil
        end

        def token_owner(_entity)
          # This is so that extra token uses bond railway
          # despite it not being active. This is for 2 player
          # when last 4 (or 5) train is bought to place 2nd token.
          return bond_railway if extra_token_entity

          super
        end

        # Used during initial drafting, for two player variant
        def any_stacks_left?
          remaining_stacks.positive?
        end

        # Used during first stock round. Need special handling if initial drafting.
        def buyable_bank_owned_companies
          available = super
          return available unless two_player?
          return available unless any_stacks_left?

          available.select!(&:stack)
          if (single_stack = available.group_by(&:stack).find { |_stack, companies| companies.size == 1 })
            available.select! { |c| c.stack == single_stack.first }
          end
          available.sort_by(&:stack)
        end

        def remaining_stacks
          @companies.select { |c| c.stack && !c.closed? }.group_by(&:stack).size
        end

        def return_kk_token(selected_token)
          selected = selected_token == 1 ? kk.placed_tokens.dup.first : kk.placed_tokens.dup.last
          selected.remove!
          kk.tokens.last.price = 100
          @kk_token_choice_player = nil
        end

        private

        def potentially_form_nationals
          if @sd_to_form
            national = corporation_by_id('SD')
            form_national_railway!(national, sd_minors)
            @sd_to_form = false
          end
          if @ug_to_form
            national = corporation_by_id('UG')
            form_national_railway!(national, ug_minors)
            @ug_to_form = false
          end
          return unless @kk_to_form

          national = corporation_by_id('KK')
          form_national_railway!(national, kk_minors)
          possibly_return_kk_token
          @kk_to_form = false
        end

        def player_loan_interest(loan)
          (loan * 0.5).ceil
        end

        def mine_hex?(hex)
          option_cisleithania ? MINE_HEX_NAMES_CISLEITHANIA.include?(hex.name) : MINE_HEX_NAMES.include?(hex.name)
        end

        def bukowina_bonus_amount(_route, stops)
          return 0 unless option_cisleithania
          return 0 unless stops.any? { |s| BUKOWINA_SOURCES.include?(s.hex.name) }
          return 0 unless stops.any? { |s| BUKOWINA_TARGETS.include?(s.hex.name) }

          # Rule X.4, last bullet: Run from Vienna/Prag to one of the Bukowina hexes
          # gives a bonus of 50 Gulden. Bukowina bonus also applies for 3 player games
          # on same map, although rule book does not explicitly state this.
          50
        end

        MOUNTAIN_RAILWAY_DEFINITION = {
          sym: 'B%1$d',
          name: 'B%1$d %2$s',
          value: 120,
          revenue: 25,
          desc: 'When the first 3 train has been bought, during an SR, this Mountain Railway can be exchanged '\
                'for a regular share in any Regional Railway. As soon as the first 4 train is bought all remaining '\
                'Mountain Railways will directly do a mandatory exchange, in numerical ascending order. '\
                'If no Regional Railway shares are available from IPO, this private is lost without compensation. '\
                'A Mountain Railway cannot otherwise be sold. %1$s has order number: %2$d',
          color: :gray,
          meta: { type: :mountain_railway },
          abilities: [
            {
              type: 'no_buy',
              owner_type: 'player',
            },
            {
              type: 'exchange',
              description: 'Exchange for share in available Regional Railway',
              corporations: %w[CL BH BK MS SB],
              owner_type: 'player',
              when: 'any', # Need to be able to use in SR and during forced exchange in OR
              from: %w[ipo market],
            },
          ],
        }.freeze

        def mountain_railway_definition(index)
          real_index = index + 1
          definition = MOUNTAIN_RAILWAY_DEFINITION.dup
          definition[:sym] = format(definition[:sym], real_index)
          definition[:name] = format(definition[:name], real_index, MOUNTAIN_RAILWAY_NAMES[real_index])
          definition[:desc] = format(definition[:desc], MOUNTAIN_RAILWAY_NAMES[real_index], real_index)
          definition
        end

        def select_randomly(collection)
          collection.min_by { rand }
        end

        def stackify(company, header)
          return header unless company.stack

          real_header = "#{header} STACK #{company.stack}"
          real_header += ' (CR)' if company.stack == 1
          real_header
        end

        def setup_companies_for_two_players(companies)
          available = companies.reject(&:closed?)
          coal_companies = available.select { |c| c.meta[:type] == :coal }
          pre_staatsbahns_primary = available.select { |c| c.meta[:type] == :pre_staatsbahn_primary }
          pre_staatsbahns_secondary = available.select { |c| c.meta[:type] == :pre_staatsbahn_secondary }

          # Follow X.3 Setup, with slight modification
          # 1. Let 2nd player select one from stack 1-3, 1st player gets the other in stack
          # 2. Repeat step 2 for player 1 first, player 2 second
          # 3. Let 2nd player buy CR from stack 4 (and par associated Regional) and player 1 buy (and par) the other
          # That completes the initial drafting

          # Place remaining companies in their stacks, preparing for initial drafting
          select_randomly(coal_companies).stack = 1
          select_randomly(pre_staatsbahns_secondary).stack = 1
          pre_staatsbahns_primary.each { |c| c.stack = 2 }
          pre_staatsbahns_secondary.select { |c| c.stack.nil? }.each { |c| c.stack = 3 }
          coal_companies.select { |c| c.stack.nil? }.each { |c| c.stack = 4 }

          # Adjust descriptions so they match 2 player rules
          companies.select { |c| c.sym == 'KK1' }.each do |c|
            # Rule X.4, bullet 1: KK is formed when 1st 5 train is bought
            c.desc = c.desc.gsub(/first 6 train/, 'first 5 train')
          end
          pre_staatsbahns_secondary.select { |c| c.stack == 1 }.each do |c|
            # Rule X.3, penultimate paragraph: if KK1 is in stack 1, close construction corporations
            # when 1st 5 train is bought, otherwise close when 1st 4 train is bought
            @close_construction_company_when_first_5_sold = (c.sym == 'KK2')

            # According to rule clarification, see https://boardgamegeek.com/thread/2929817/questions-about-2-player-variant
            c.make_construction_company!

            desc = 'Buyer take control of pre-staatsbahn XXX. That Railway will be a Construction Company '\
                   'which just builds track, for free - no treasury or trains. '\
                   "When first #{closed_construction} train is bought XXX closes, and #{format_currency(c.value)} "\
                   'is added to the treasury of YYY. XXX cannot be exchanged for any shares, and no shares are reserved.'
            c.desc = desc.gsub(/XXX/, c.sym).gsub(/YYY/, c.sym[0..-1])
          end
          coal_companies.select { |c| c.stack == 1 }.each do |c|
            # According to rule clarification, see https://boardgamegeek.com/thread/2929817/questions-about-2-player-variant
            c.make_construction_company!

            desc = 'Buyer take control of minor Coal Railway XXX. That Railway will be a Construction Company '\
                   'which just builds track, for free - no treasury or trains. '\
                   "When first #{closed_construction} train is bought XXX closes, and nothing is added to YYY treasury. "\
                   'XXX cannot be exchanged for any shares, and no shares are reserved.'
            c.desc = desc.gsub(/XXX/, c.sym).gsub(/YYY/, associated_regional_name(c))
          end
        end

        def closed_construction
          @close_construction_company_when_first_5_sold ? '5' : '4'
        end

        def adjust_events_for_two_players(train)
          # KK forms on 5 trains instead of 6 trains, and UG is not present when 2 players
          close_construction_event = 'close_construction_railways'

          if train[:name] == '4' && !@close_construction_company_when_first_5_sold
            train[:events] = add_event(train, close_construction_event)
          end

          if train[:name] == '5'
            train[:events] = [{ 'type' => 'exchange_coal_companies' }, { 'type' => 'kk_formation' }]
            train[:events] = add_event(train, close_construction_event) if @close_construction_company_when_first_5_sold
            train[:events] = add_event(train, 'vienna_tokened')
          end

          train[:events] = [] if train[:name] == '6'

          train
        end

        def add_event(train, event)
          events = train[:events]
          added_event = { 'type' => event }

          events << added_event unless events.include?(added_event)

          events
        end

        def create_construction_railway_from_bought_pre_staatsbahn(company, minor)
          make_minor_construction_railway(minor)

          national = corporation_by_id(company.sym[0..-2])
          national.unreserve_one_share!
        end

        def create_construction_railways_from_coal_mine(company, minor)
          regional = get_associated_regional_railway(minor)
          make_minor_construction_railway(minor)

          regional.make_bond_railway!
          share_price = stock_market.share_price([6, 1]) # This is the lower one at 50G
          stock_market.set_par(regional, share_price)
          regional.shares.each do |s|
            @share_pool.transfer_shares(s.to_bundle, @share_pool, price: 0, allow_president_change: false)
          end

          # Tokens placed via events should be free
          regional.tokens.each { |t| t.price = 0 }

          association = "the associated Regional Railway of #{company.sym}"
          log << "#{regional.name} (#{association}) pars at #{format_currency(share_price.price)}."
          log << "#{regional.name} will not build or run trains but shareholders will receive current stock value "\
                 'in revenue each OR.'
        end

        def make_minor_construction_railway(minor)
          @log << "#{minor.name} returns its cash to the bank as it does not use any money."
          minor.spend(minor.cash, @bank)
          minor.add_ability(free_tile_lay_ability)
          minor.make_construction_railway!
        end

        def free_tile_lay_ability
          Engine::Ability::TileLay.new(
            type: 'tile_lay',
            tiles: [],
            hexes: [],
            closed_when_used_up: false,
            reachable: true,
            free: true,
            special: false,
            consume_tile_lay: true,
            when: 'track'
          )
        end

        def possibly_return_kk_token
          if kk.placed_tokens.size == 2
            cities_with_kk_tokens = kk.placed_tokens.map(&:city).uniq
            if cities_with_kk_tokens.size == 2
              # KK tokens in two different cities in Wien, so owning player gets to choose which to remove
              @log << "Both KK tokens are in different cities in E12, so #{kk.owner.name} to select one to return to charter"
              @kk_token_choice_player = kk.owner
            else
              # KK tokens in same city in Wien, so return the last one placed
              @log << 'Both KK tokens are in the same city in E12, so the last one placed is returned to the bank'
              return_kk_token(2)
            end
          else
            # Only one token, so nothing to remove (this is a case when one KK pre-stadtsbahn not sold)
            @log << 'Only one KK token on board so no token to return to charter'
            @kk_token_choice_player = nil
          end
        end
      end
    end
  end
end
