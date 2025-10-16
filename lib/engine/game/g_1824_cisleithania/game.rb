# frozen_string_literal: true

require_relative '../g_1824/game'
require_relative 'company'
require_relative 'map'
require_relative 'meta'
require_relative 'trains'

module Engine
  module Game
    module G1824Cisleithania
      class Game < G1824::Game
        include_meta(G1824Cisleithania::Meta)
        include G1824Cisleithania::Map
        include G1824Cisleithania::Trains

        CORPORATION_CLASS = G1824Cisleithania::Corporation

        # Rule X.2 Cislethania 2p, XI.2 Cislethania 3p
        # Note! 700 for 3 players is a correction. The rule book has incorrect 680.
        # Ref: https://boardgamegeek.com/thread/2342047/3-player-cisleithania-starting-treasury-error
        STARTING_CASH = { 2 => 830, 3 => 700 }.freeze

        # Rule X.1 Cislethania 2p, XI.1 Cislethania 3p
        BANK_CASH = { 2 => 4000, 3 => 9000 }.freeze

        # Rule X.2 Cislethania 2p, XI.2 Cislethania 3p
        CERT_LIMIT = { 2 => 14, 3 => 16 }.freeze

        # Used for Bukowina bonus on the Cisleithania map
        # Bukowina bonus is for a route that included Prag/Vienna and one of the 3 green hexes in the East
        BUKOWINA_SOURCES = %w[E12 B9].freeze
        BUKOWINA_TARGETS = %w[D25 E24 E26].freeze

        EVENTS_TEXT = G1824::Game::EVENTS_TEXT.dup.merge(
          'close_construction_railways' => ['Close Construction Railways', 'All construction minors are closed'],
          'vienna_tokened' => ['Vienna tokened',
                               'When Vienna is upgraded to Brown the last token of the bond railway is placed there'],
        ).freeze

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

        def game_trains
          return super unless two_player?

          unless @game_trains
            trains = super.map(&:dup)

            _train_2, _train_3, train_4, train_5, train_6, _train_8, _train_10,
            _train_1g, _train_2g, _train_3g, _train_4g, _train_5g = trains

            train_4_events = train_4[:events].dup
            train_4_events << { 'type' => 'close_construction_railways' } unless @close_construction_company_when_first_5_sold

            # KK forms on 5 trains instead of 6 trains, and UG is not present when 2 players
            train_5_events = [{ 'type' => 'exchange_coal_companies' }, { 'type' => 'kk_formation' },
                              { 'type' => 'vienna_tokened' }]
            train_5_events << { 'type' => 'close_construction_railways' } if @close_construction_company_when_first_5_sold

            train_4[:events] = train_4_events
            train_5[:events] = train_5_events
            train_6[:events] = []

            @game_trains = trains.deep_freeze
          end
          @game_trains
        end

        def num_trains_map
          if two_player?
            self.class::TRAIN_COUNT_2P_CISLETHANIA.freeze
          else
            self.class::TRAIN_COUNT_3P_CISLETHANIA.freeze
          end
        end

        def game_corporations
          corporations = CORPORATIONS.dup

          return corporations if two_player?

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

          corporations
        end

        def init_corporations(stock_market)
          all = super

          if two_player?
            # Rule X.1: Remove Pre-Staatsbahns UG1 and UG2, Regionals BH and SB, Coal mine SPB
            all.select { |c| %w[UG UG1 UG2 BH SB SPB].include?(c.id) }.each(&:close!)
          else
            # Rule XI.1: Remove Pre-Staatsbahn UG2, Regionals BH and SB, Coal mine SPB
            all.select { |c| %w[UG2 BH SB SPB].include?(c.id) }.each(&:close!)
          end

          all
        end

        def init_companies(players)
          companies = COMPANIES.dup

          mountain_railway_count = players.size
          mountain_railway_count.times { |index| companies << mountain_railway_definition(index) }

          # Rule X.1/XI.1: Remove Coal mine SPB, Pre-Staatsbahn UG2, and - if 2 players - UG1
          removed_companies = players.size == 2 ? %w[SPB UG2 UG1] : %w[SPB UG2]
          companies.reject! { |m| removed_companies.include?(m[:sym]) }

          used_companies = companies.map { |company| G1824Cisleithania::Company.new(**company) }

          # Rule X.3 Setup, need to do some modifications of companies for two players
          # and need to do it before trains which also are affected
          setup_companies_for_two_players(used_companies) if two_player?

          used_companies
        end

        def init_tiles
          tiles = TILES.dup

          # Remove all Budapest specific tiles as Budapest is an offboard city in Cisleithania
          %w[126 490 495 498].each { |name| tiles.delete(name) }

          tiles.flat_map do |name, val|
            init_tile(name, val)
          end
        end

        def init_share_pool
          G1824Cisleithania::SharePool.new(self)
        end

        # Modified from 1837 as 1824 does not have single shares in Pre-staatsbahn
        def company_header(company)
          header = super
          stackify(company, header)
        end

        def sold_shares_destination(_entity)
          return super unless two_player?

          # Rule X.4, bullet 2 - 2 player 1824 has a bank pool
          :bank
        end

        def location_name(coord)
          unless @location_names
            @location_names = LOCATION_NAMES.dup
            @location_names['F25'] = 'Kronstadt'
            @location_names['G12'] = 'Budapest'
            @location_names['I10'] = 'Bosnien'
          end
          @location_names[coord]
        end

        def init_round
          @log << '-- First Stock Round --'
          G1824Cisleithania::Round::FirstStock.new(self, [
            G1824Cisleithania::Step::BuySellParSharesFirstSr,
          ])
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            G1824::Step::KkTokenChoice, # In case train export triggers KK formation
            G1824::Step::DiscardTrain,
            G1824::Step::ForcedMountainRailwayExchange, # In case train export after OR set triggers exchage
            G1824Cisleithania::Step::BuySellParExchangeShares,
          ])
        end

        def operating_round(round_num)
          G1824::Round::Operating.new(self, [
            G1837::Step::Bankrupt,
            G1824::Step::KkTokenChoice,
            G1824::Step::DiscardTrain,
            G1824Cisleithania::Step::BondToken,
            G1824::Step::ForcedMountainRailwayExchange, # In case train export after OR set triggers exchage
            Engine::Step::SpecialTrack,
            G1824Cisleithania::Step::Track,
            G1824Cisleithania::Step::Token,
            Engine::Step::Route,
            G1824Cisleithania::Step::Dividend,
            G1824Cisleithania::Step::BuyTrain,
          ], round_num: round_num)
        end

        def setup
          super

          # Used in two-player for extra tokening when last 4 sold (or last 5, if were exported)
          @train_based_bond_token_used = false
          @corporation_to_put_train_based_bond_token = nil

          # Used in two-player for extra tokening when Wien upgraded to brown
          @upgrade_based_bond_token_used = false
          @corporation_to_put_upgrade_based_bond_token = nil

          # Used in two-player game when construction company should be closed
          @close_construction_company_when_first_5_sold = false
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
          else
            super
          end
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

        def revenue_for(route, stops)
          super + bukowina_bonus_amount(route, stops)
        end

        def revenue_str(route)
          str = super
          str += ' + Bukowina' if bukowina_bonus_amount(route, route.stops).positive?
          str
        end

        def bond_railway
          @bond_railway ||= @corporations.find { |c| bond_railway?(c) }
        end

        def bond_railway?(entity)
          entity.type == :bond_railway
        end

        def construction_railway?(entity)
          entity.type == :construction_railway
        end

        def minor_for_partition_of_or?(corp)
          super || construction_railway?(corp)
        end

        # Used for MR exchange. Do allow bond railway shares to be exchanged as well.
        def shares_exchangable?(corporation)
          super || bond_railway(corporation)
        end

        # Rule X.4, should be able to sell bundles with presidency share (if bond railway)
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

        def after_buy_company_final_touch(company, minor, price)
          return super unless two_player?

          stack = company.stack
          company.stack = nil

          # Construction railways is in stack 1
          return super unless stack == 1

          if pre_staatsbahn?(minor)
            handle_unreserve_of_pre_staatsbahn(company)
          else
            create_bond_railway(company, minor)
          end
          minor.make_construction_railway!(self, minor)
        end

        private

        def bukowina_bonus_amount(_route, stops)
          return 0 unless stops.any? { |s| BUKOWINA_SOURCES.include?(s.hex.name) }
          return 0 unless stops.any? { |s| BUKOWINA_TARGETS.include?(s.hex.name) }

          # Rule X.4, last bullet: Run from Vienna/Prag to one of the Bukowina hexes
          # gives a bonus of 50 Gulden. Bukowina bonus also applies for 3 player games
          # on same map, although rule book does not explicitly state this.
          50
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

        def select_randomly(collection)
          collection.min_by { rand }
        end

        def stackify(company, header)
          return header unless company.stack

          case company.stack
          when 1 then 'Construction Railway (Stack 1)'
          when 2 then 'Large Pre-staatsbahn (Stack 2)'
          when 3 then 'Small Pre-staatsbahn (Stack 3)'
          when 4 then 'Coal Railway (Stack 4)'
          end
        end

        def closed_construction
          @close_construction_company_when_first_5_sold ? '5' : '4'
        end

        def handle_unreserve_of_pre_staatsbahn(company)
          national = corporation_by_id(company.sym[0..-2])
          national.unreserve_one_share!
        end

        def create_bond_railway(company, minor)
          regional = get_associated_regional_railway(minor)

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
      end
    end
  end
end
