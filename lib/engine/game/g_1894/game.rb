# frozen_string_literal: true

require_relative '../base'
require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative '../stubs_are_restricted'

module Engine
  module Game
    module G1894
      class Game < Game::Base
        include_meta(G1894::Meta)
        include G1894::Map
        include G1894::Entities
        include StubsAreRestricted

        CURRENCY_FORMAT_STR = '%d F'

        BANK_CASH = 8000

        CERT_LIMIT = { 3 => 99, 4 => 99, 5 => 99 }.freeze

        STARTING_CASH = { 3 => 650, 4 => 550 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        MARKET = [
          %w[60o
             67
             71
             76
             82
             90
             100p
             112
             126
             142
             160
             180
             200
             225
             255
             285
             325
             375
             425],
          %w[53o
             60o
             66
             70
             76
             82
             90p
             100
             112
             126
             142
             160
             180
             200
             225
             250
             275
             300
             330],
          %w[46o
             55o
             60o
             65
             70
             76
             82p
             90
             100
             111
             125
             140
             155
             170
             190
             210],
          %w[39o
             48o
             54o
             60o
             66
             71
             76p
             82
             90
             100
             110
             120
             130],
          %w[32o 41o 48o 55o 62 67 71p 76 82 90 100],
          %w[25o 34o 42o 50o 58o 65 67p 71 75 80],
          %w[18o 27o 36o 45o 54o 63 67 69 70],
          %w[10o 20o 30o 40o 50o 60o 67 68],
          ['', '10o', '20o', '30o', '40o', '50o', '60o'],
          ['', '', '10o', '20o', '30o', '40o', '50o'],
          ['', '', '', '10o', '20o', '30o', '40o'],
        ].freeze

        PHASES = [{ name: 'Yellow', train_limit: 4, tiles: [:yellow], operating_rounds: 1 },
                  {
                    name: 'Green',
                    on: '3',
                    train_limit: 4,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: ['can_buy_companies'],
                  },
                  {
                    name: 'Blue',
                    on: '4',
                    train_limit: 3,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: ['can_buy_companies'],
                  },
                  {
                    name: 'Brown',
                    on: '5',
                    train_limit: 3,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                    status: ['can_buy_companies'],
                  },
                  {
                    name: 'Red',
                    on: '6',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: 'Gray',
                    on: '7',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: 'Purple',
                    on: 'D',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  }].freeze

        TRAINS = [{ name: '2', distance: 2, price: 80, rusts_on: '4', num: 7 },
                  {
                    name: '3',
                    distance: 3,
                    price: 160,
                    rusts_on: '5',
                    num: 5,
                    discount: { '2' => 40 },
                  },
                  {
                    name: '4',
                    distance: 4,
                    price: 300,
                    rusts_on: '7',
                    num: 3,
                    discount: { '3' => 80 },
                  },
                  {
                    name: '5',
                    distance: 5,
                    price: 400,
                    rusts_on: 'D',
                    num: 4,
                    events: [{ 'type' => 'late_corporations_available' }],
                    discount: { '4' => 150 },
                  },
                  {
                    name: '6',
                    distance: 6,
                    price: 600,
                    num: 3,
                    events: [{ 'type' => 'close_companies' }],
                    discount: { '5' => 200 },
                  },
                  {
                    name: '7',
                    distance: 7,
                    price: 750,
                    num: 3,
                    discount: { '6' => 300 },
                  },
                  {
                    name: 'D',
                    distance: 999,
                    price: 900,
                    num: 20,
                    discount: { '5' => 200, '6' => 300, '7' => 375 },
                  }].freeze

        LAYOUT = :pointy

        MULTIPLE_BUY_TYPES = %i[unlimited].freeze

        MUST_BID_INCREMENT_MULTIPLE = true
        MIN_BID_INCREMENT = 5

        ASSIGNMENT_TOKENS = {
          'PC' => '/icons/1894/pc_token.svg',
        }.freeze

        TILE_RESERVATION_BLOCKS_OTHERS = false

        GAME_END_CHECK = {
          bankrupt: :immediate,
          bank: :full_or,
        }.freeze

        SELL_BUY_ORDER = :sell_buy_sell

        NEXT_SR_PLAYER_ORDER = :first_to_pass

        TRACK_RESTRICTION = :permissive

        DISCARDED_TRAINS = :remove

        MARKET_SHARE_LIMIT = 50 # percent

        MARKET_TEXT = Base::MARKET_TEXT.merge(par: 'Par',
                                              unlimited: 'Corporation shares can be held above 60% and ' \
                                                         'President may buy two shares at a time and ' \
                                                         'additional move up if sold out.')

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par: :red,
                                                            unlimited: :gray)

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          late_corporations_available: ['Late corporations are now available'],
        ).freeze

        ENGLAND_HEX = 'A10'
        ENGLAND_FERRY_SUPPLY = 'A8'
        FERRY_MARKER_ICON = 'ferry'
        FERRY_MARKER_COST = 60

        PARIS_HEX = 'G4'
        SQG_HEX = 'G10'

        AMIENS_HEX = 'E6'
        AMIENS_TILE = 'X3'

        GREEN_CITY_TILES = %w[14 15 619].freeze

        def stock_round
          G1894::Round::Stock.new(self, [
            G1894::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::Assign,
            Engine::Step::BuyCompany,
            G1894::Step::SpecialBuy,
            Engine::Step::HomeToken,
            G1894::Step::Track,
            G1894::Step::Token,
            G1894::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1894::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def setup
          @late_corporations, @corporations = @corporations.partition do |c|
            %w[F1 F2 B1 B2].include?(c.id)
          end

          @log << "-- Setting game up for #{@players.size} players --"
          remove_extra_trains
          remove_extra_late_corporations

          @ferry_marker_ability =
            Engine::Ability::Description.new(type: 'description', description: 'Ferry marker')
          block_england

          plm = corporations.find { |c| c.id == 'PLM' }
          paris_tiles_names = %w[X1 X4 X5 X7 X8]
          paris_tiles = @all_tiles.select { |t| paris_tiles_names.include?(t.name) }
          paris_tiles.each { |t| t.add_reservation!(plm, 0) }
        end

        def init_stock_market
          Engine::StockMarket.new(self.class::MARKET, [],
                                  multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
        end

        def event_late_corporations_available!
          @log << "-- Event: #{EVENTS_TEXT['late_corporations_available'][0]} --"
          @corporations.concat(@late_corporations)
          @late_corporations = []
        end

        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: true, upgrade: :not_if_upgraded, cost: 20, cannot_reuse_same_hex: true },
        ].freeze

        def can_hold_above_corp_limit?(_entity)
          true
        end

        def show_game_cert_limit?
          false
        end

        def init_round_finished
          @players.rotate!(@round.entity_index)
        end

        def upgrades_to?(from, to, _special = false, selected_company: nil)
          return to.name == AMIENS_TILE if from.hex.name == AMIENS_HEX && from.color == :white
          return GREEN_CITY_TILES.include?(to.name) if from.hex.name == AMIENS_HEX && from.color == :yellow

          super
        end

        def revenue_for(route, stops)
          revenue = super
          revenue += pc_bonus(route.corporation, stops)
          revenue += est_le_sud_bonus(route.corporation, stops)
          revenue
        end

        def pc_bonus(corp, stops)
          corp.assigned?('PC') && stops.any? { |s| s.hex.assigned?('PC') } ? 10 : 0
        end

        def est_le_sud_bonus(corp, stops)
          corp.id == 'Est' && stops.any? { |s| s.hex.id == 'I2' } ? 20 : 0
        end

        def ferry_marker_available?
          hex_by_id(ENGLAND_FERRY_SUPPLY).tile.icons.any? { |icon| icon.name == FERRY_MARKER_ICON }
        end

        def ferry_marker?(entity)
          return false unless entity.corporation?

          !ferry_markers(entity).empty?
        end

        def ferry_markers(entity)
          entity.all_abilities.select { |ability| ability.description == @ferry_marker_ability.description }
        end

        def connected_to_england?(entity)
          graph.reachable_hexes(entity).include?(hex_by_id(ENGLAND_HEX))
        end

        def can_buy_ferry_marker?(entity)
          return false unless entity.corporation?

          ferry_marker_available? &&
            !ferry_marker?(entity) &&
            buying_power(entity) >= FERRY_MARKER_COST &&
            connected_to_england?(entity)
        end

        def buy_ferry_marker(entity)
          return unless can_buy_ferry_marker?(entity)

          entity.spend(FERRY_MARKER_COST, @bank)
          entity.add_ability(@ferry_marker_ability.dup)
          @log << "#{entity.name} buys a ferry marker for $#{FERRY_MARKER_COST}"

          tile_icons = hex_by_id(ENGLAND_FERRY_SUPPLY).tile.icons
          tile_icons.reject! { |icon| icon.name == FERRY_MARKER_ICON }

          graph.clear
        end

        def block_england
          england = hex_by_id(ENGLAND_HEX).tile.cities.first

          england.instance_variable_set(:@game, self)

          def england.blocks?(corporation)
            !@game.ferry_marker?(corporation)
          end
        end

        private

        def remove_extra_trains
          return unless @players.size == 3

          to_remove = @depot.trains.reverse.find { |t| t.name == '5' }
          @depot.forget_train(to_remove)
          @log << "Removing #{to_remove.name} train"
        end

        def remove_extra_late_corporations
          return unless @players.size == 3

          to_remove = @late_corporations.select { |c| %w[F2 B2].include?(c.id) }
          @late_corporations.delete(to_remove[0])
          @late_corporations.delete(to_remove[1])
          @log << 'Removing F2 and B2 late corporations'
        end
      end
    end
  end
end
