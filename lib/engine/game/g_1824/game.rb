# frozen_string_literal: true

require_relative '../g_1837/game'
require_relative 'meta'
require_relative '../base'
require_relative '../g_1837/round/exchange'
require_relative 'round/operating'
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

        # Rule III.3 standard game
        STARTING_CASH = { 3 => 820, 4 => 680, 5 => 560, 6 => 460 }.freeze

        # Rule III.4 standard game
        BANK_CASH = 12_000

        # Rule VI.7 standard game
        CERT_LIMIT = { 3 => 21, 4 => 16, 5 => 13, 6 => 11 }.freeze

        # Rule VII.13, bullet 3
        DISCARDED_TRAINS = :remove

        # Differ from 1837, rule VII.5, bullet 1: placed when first operating
        HOME_TOKEN_TIMING = :operate

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

        ASSIGNMENT_TOKENS = {
          'coal' => '/icons/1837/coalcar.svg',
        }.freeze

        # Modified from 1837 as 1824 does not have single shares in Pre-staatsbahn
        def company_header(company)
          return 'COAL COMPANY' if company.color == :black
          return 'MOUNTAIN RAILWAY' if company.color == :gray

          'MINOR COMPANY'
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

        # Rule VI.78, bullet 4: Cannot buy if holding 60% or more
        # but can exceed via exchanges
        def can_hold_above_corp_limit?(_entity)
          true
        end

        # Modified base version as the number of trains vary between player count and variant
        def init_train_handler
          train_count_map = num_trains_map
          trains = game_trains.flat_map do |train|
            t = train
            t = possibly_adjust_events_based_on_player_count(t)
            Array.new(train_count_map[t[:name]]) do |index|
              Train.new(**t, index: index)
            end
          end

          G1824::Depot.new(trains, self)
        end

        def num_trains_map
          self.class::TRAIN_COUNT_STANDARD
        end

        def possibly_adjust_events_based_on_player_count(train)
          train
        end

        def init_companies(players)
          companies = COMPANIES.dup

          mountain_railway_count =
            case players.size
            when 2
              2
            when 3, 6
              4
            when 4, 5
              6
            end
          mountain_railway_count.times { |index| companies << mountain_railway_definition(index) }

          companies.map { |company| Engine::Company.new(**company) }
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

          tiles.flat_map do |name, val|
            init_tile(name, val)
          end
        end

        def option_goods_time
          @optional_rules&.include?(:goods_time)
        end

        def optional_hexes
          map_optional_hexes
        end

        def sold_shares_destination(_entity)
          # Rule VI.8 - 1824 has no bank pool
          :corporation
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
            Engine::Step::SpecialTrack,
            Engine::Step::Track,
            Engine::Step::Token,
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

        def status_str(entity)
          if coal_railway?(entity)
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

        def corporation_available?(entity)
          buyable?(entity)
        end

        def unbought_companies?
          !buyable_bank_owned_companies.empty?
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

          return if special_handling_after_by_company(company, minor)

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

        # Needed for 2 player variant
        def special_handling_after_by_company(_company, _minor)
          false
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

          super
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
            'UG formation to float'
          when 'KK'
            'KK formation to float'
          when 'SD'
            'SD formation to float'
          else
            super
          end
        end

        # Simplified version compared to 1837, and also 1824 does
        # not place home tokens until a corporation (even minor) operate.
        def float_minor!(minor, price)
          cash = minor_initial_cash(minor, price)
          @bank.spend(cash, minor)
          @log << "#{minor.name} receives #{format_currency(cash)}"
          minor.floated = true
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

        def return_kk_token(selected_token)
          selected = selected_token == 1 ? kk.placed_tokens.dup.first : kk.placed_tokens.dup.last
          selected.remove!
          kk.tokens.first.price = 40
          kk.tokens.last.price = 100
          @kk_token_choice_player = nil
        end

        def return_token(national)
          price =
            case national.tokens.size
              when 4
                0
              when 3
                40
              else
                100
            end
          token = Engine::Token.new(national, price: price)
          national.tokens.unshift(token)
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
