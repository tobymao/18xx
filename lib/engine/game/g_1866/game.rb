# frozen_string_literal: true

require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative '../base'

module Engine
  module Game
    module G1866
      class Game < Game::Base
        include_meta(G1866::Meta)
        include G1866::Entities
        include G1866::Map

        GAME_END_CHECK = { bank: :full_or, stock_market: :current_or }.freeze

        BANKRUPTCY_ALLOWED = false
        CURRENCY_FORMAT_STR = '£%d'
        BANK_CASH = 99_999

        CERT_LIMIT = { 3 => 40, 4 => 30, 5 => 24, 6 => 20, 7 => 17 }.freeze
        STARTING_CASH = { 3 => 800, 4 => 600, 5 => 480, 6 => 400, 7 => 340 }.freeze

        CAPITALIZATION = :incremental

        EBUY_OTHER_VALUE = false

        TILE_TYPE = :lawson
        LAYOUT = :pointy

        HOME_TOKEN_TIMING = :operate
        MUST_BID_INCREMENT_MULTIPLE = true
        MUST_BUY_TRAIN = :always
        NEXT_SR_PLAYER_ORDER = :least_cash

        MUST_SELL_IN_BLOCKS = false
        SELL_AFTER = :first
        SELL_BUY_ORDER = :sell_buy
        SELL_MOVEMENT = :down_share
        SOLD_OUT_INCREASE = false

        MARKET = [
          %w[0 5 10 15 20 25 30p 35p 40p 45p 50p 55p 60x 65x 70x 75x 80x 90x 100z 110z 120z 135z 150w 165w 180
             200 220 240 260 280 300 330 360 390 420 460 500 540 580 630 680],
          %w[0 5 10 15 20 25 30p 35p 40p 45p 50p 55p 60p 65p 70p 75p 80x 90x 100x 110x 120z 135z 150z 165w 180w
             200 220 240 260 280 300 330 360 390 420 460 500 540 580 630 680],
          %w[0 5 10 15 20 25 30 35 40 45 50 55 60p 65p 70p 75p 80p 90p 100p 110x 120x 135x 150z 165z 180w
             200pxzw 220 240 260 280 300 330 360 390 420 460 500 540 580 630 680],
          %w[120P 100P 75P 75P 75P 120P 80P 80P 80P 50P],
        ].freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(par_overlap: 'Minor nationals',
                                              par: 'Yellow phase (L/2) par',
                                              par_1: 'Green phase (3/4) par',
                                              par_2: 'Brown phase (5/6) par',
                                              par_3: 'Gray phase (8/10) par').freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par_overlap: :white,
                                                            par: :yellow,
                                                            par_1: :green,
                                                            par_2: :brown,
                                                            par_3: :gray).freeze

        PHASES = [
          {
            name: 'L/2',
            on: '',
            train_limit: { minor_national: 1, national: 1, public_5: 3 },
            tiles: [:yellow],
            operating_rounds: 99,
          },
          {
            name: '3',
            on: '3',
            train_limit: { minor_national: 1, national: 1, public_5: 3, public_10: 4 },
            tiles: %i[yellow green],
            operating_rounds: 99,
          },
          {
            name: '4',
            on: '4',
            train_limit: { minor_national: 1, national: 1, public_5: 3, public_10: 4 },
            tiles: %i[yellow green],
            operating_rounds: 99,
          },
          {
            name: '5',
            on: '5',
            train_limit: { minor_national: 1, national: 1, public_5: 2, public_10: 3 },
            tiles: %i[yellow green brown],
            operating_rounds: 99,
          },
          {
            name: '6',
            on: '6',
            train_limit: { minor_national: 1, national: 1, public_5: 2, public_10: 3 },
            tiles: %i[yellow green brown],
            operating_rounds: 99,
          },
          {
            name: '8',
            on: '8',
            train_limit: { minor_national: 1, national: 1, public_5: 1, public_10: 2 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 99,
          },
          {
            name: '10',
            on: '10',
            train_limit: { minor_national: 1, national: 1, public_5: 1, public_10: 2 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 99,
          },
        ].freeze

        TRAINS = [
          {
            name: 'L',
            distance: [
              {
                'nodes' => ['city'],
                'pay' => 1,
                'visit' => 1,
              },
              {
                'nodes' => ['town'],
                'pay' => 1,
                'visit' => 1,
              },
            ],
            num: 14,
            price: 50,
            obsolete_on: '3',
            variants: [
              {
                name: '2',
                distance: [
                  {
                    'nodes' => %w[city offboard],
                    'pay' => 2,
                    'visit' => 2,
                  },
                  {
                    'nodes' => ['town'],
                    'pay' => 99,
                    'visit' => 99,
                  },
                ],
                price: 100,
                obsolete_on: '4',
              },
            ],
          },
          {
            name: '3',
            distance: [
              {
                'nodes' => %w[city offboard],
                'pay' => 3,
                'visit' => 3,
              },
              {
                'nodes' => ['town'],
                'pay' => 99,
                'visit' => 99,
              },
            ],
            num: 4,
            price: 200,
            obsolete_on: '6',
          },
          {
            name: '4',
            distance: [
              {
                'nodes' => %w[city offboard],
                'pay' => 4,
                'visit' => 4,
              },
              {
                'nodes' => ['town'],
                'pay' => 99,
                'visit' => 99,
              },
            ],
            num: 4,
            price: 300,
            obsolete_on: '8',
          },
          {
            name: '5',
            distance: [
              {
                'nodes' => %w[city offboard],
                'pay' => 5,
                'visit' => 5,
              },
              {
                'nodes' => ['town'],
                'pay' => 99,
                'visit' => 99,
              },
            ],
            num: 4,
            price: 450,
            obsolete_on: '10',
            variants: [
              {
                name: '3E',
                distance: [
                  {
                    'nodes' => ['city'],
                    'pay' => 3,
                    'visit' => 3,
                  },
                  {
                    'nodes' => ['town'],
                    'pay' => 0,
                    'visit' => 99,
                  },
                ],
                multiplier: 2,
                price: 450,
                obsolete_on: '10',
              },
            ],
          },
          {
            name: '6',
            distance: [
              {
                'nodes' => %w[city offboard],
                'pay' => 6,
                'visit' => 6,
              },
              {
                'nodes' => ['town'],
                'pay' => 99,
                'visit' => 99,
              },
            ],
            num: 4,
            price: 600,
            variants: [
              {
                name: '4E',
                distance: [
                  {
                    'nodes' => ['city'],
                    'pay' => 4,
                    'visit' => 4,
                  },
                  {
                    'nodes' => ['town'],
                    'pay' => 0,
                    'visit' => 99,
                  },
                ],
                multiplier: 2,
                price: 600,
              },
            ],
          },
          {
            name: '8',
            distance: [
              {
                'nodes' => %w[city offboard],
                'pay' => 8,
                'visit' => 8,
              },
              {
                'nodes' => ['town'],
                'pay' => 99,
                'visit' => 99,
              },
            ],
            num: 4,
            price: 800,
            variants: [
              {
                name: '5E',
                distance: [
                  {
                    'nodes' => ['city'],
                    'pay' => 5,
                    'visit' => 5,
                  },
                  {
                    'nodes' => ['town'],
                    'pay' => 0,
                    'visit' => 99,
                  },
                ],
                multiplier: 2,
                price: 800,
              },
            ],
          },
          {
            name: '10',
            distance: [
              {
                'nodes' => %w[city offboard],
                'pay' => 10,
                'visit' => 10,
              },
              {
                'nodes' => ['town'],
                'pay' => 99,
                'visit' => 99,
              },
            ],
            num: 20,
            price: 1000,
            variants: [
              {
                name: '6E',
                distance: [
                  {
                    'nodes' => ['city'],
                    'pay' => 6,
                    'visit' => 6,
                  },
                  {
                    'nodes' => ['town'],
                    'pay' => 0,
                    'visit' => 99,
                  },
                ],
                multiplier: 2,
                price: 1000,
              },
            ],
          },
          {
            name: 'INF',
            distance: 99,
            num: 18,
            price: 0,
            reserved: true,
          },
        ].freeze

        # *********** 1866 Specific constants ***********
        CORPORATIONS_OPERATING_RIGHTS = {
          'LNWR' => 'GBN',
          'GWR' => 'GBN',
          'NBR' => 'GBN',
          'PLM' => 'FN',
          'MIDI' => 'FN',
          'OU' => 'FN',
          'KPS' => %w[GN G1],
          'BY' => %w[GN G3],
          'KHS' => %w[GN G2],
          'SB' => 'AHN',
          'BH' => 'AHN',
          'FNR' => 'AHN',
          'SSFL' => %w[IN I5],
          'IFT' => %w[IN I1],
          'SFAI' => %w[IN I3],
          'SBB' => 'SWN',
          'GL' => 'BN',
          'NRS' => 'BN',
          'ZPB' => 'SPN',
          'MZA' => 'SPN',
        }.freeze

        LOCAL_TRAIN = 'L'
        MAX_PAR_VALUE = 200

        MINOR_NATIONAL_PAR_ROWS = {
          'G1' => [3, 0],
          'G2' => [3, 1],
          'G3' => [3, 2],
          'G4' => [3, 3],
          'G5' => [3, 4],
          'I1' => [3, 5],
          'I2' => [3, 6],
          'I3' => [3, 7],
          'I4' => [3, 8],
          'I5' => [3, 9],
        }.freeze

        NATIONAL_CORPORATIONS = %w[GBN FN AHN BN SPN SWN GN G1 G2 G3 G4 G5 IN I1 I2 I3 I4 I5].freeze
        NATIONAL_REGION_HEXES = {
          'G1' => %w[E23 E25 F20 F22 F24 F26 G15 G17 G19 G21 G23 G25 H14 H16 H18 H24 H26 I25],
          'G2' => %w[D18 E15 E17 E19 E21 F16 F18],
          'G3' => %w[I17 I19 J16 J18 J20 K17 K19 K21],
          'G4' => %w[I13 I15 J14 K15],
          'G5' => %w[H20 H22 I21 I23],
          'I1' => %w[S21 S23 T20 T22 T24 U21 V18 V20 W19],
          'I2' => %w[N12 O13 O15 S13 T12],
          'I3' => %w[M17 N14 N16 N18 N20 O17 P18],
          'I4' => %w[Q19 R18 R20 S19],
          'I5' => %w[P16 Q17],
          'AHN' => %w[J22 J24 J26 K23 K25 L18 L20 L22 L24 L26 M19 M21 M23 M25 N22 N24 N26 O21 O23 O25
                      P22 P24 P26 Q23 Q25 R24],
          'BN' => %w[E13 F10 F12 F14 G9 G11 G13 H10 H12 I11],
          'FN' => %w[H6 H8 I1 I3 I5 I7 I9 J0 J2 J4 J6 J8 J10 J12 K1 K3 K5 K7 K9 K11 K13 L2 L4 L6 L8 L10
                     M3 M5 M7 M9 M11 N2 N4 N6 N8 N10 O3 O5 O7 O9 O11 P6 P8 P10 P12 Q13],
          'GBN' => %w[A3 B2 B4 C3 C5 D2 D4 D6 E1 E3 E5 E7 F2 F4 F6 G1 G3 G5],
          'SPN' => %w[O1 P2 P4 Q1 Q3 Q5 R2 R4 S1 S3 T2 U1],
          'SWN' => %w[L12 L14 L16 M13 M15],
          'GN' => %w[E23 E25 F20 F22 F24 F26 G15 G17 G19 G21 G23 G25 H14 H16 H18 H24 H26 I25 D18 E15 E17
                     E19 E21 F16 F18 I17 I19 J16 J18 J20 K17 K19 K21 I13 I15 J14 K15 H20 H22 I21 I23],
          'IN' => %w[S21 S23 T20 T22 T24 U21 V18 V20 W19 N12 O13 O15 S13 T12 M17 N14 N16 N18 N20 O17 P18
                     Q19 R18 R20 S19 P16 Q17],
        }.freeze

        # Only need up to phase 5, all national concessions are forced to convert in phase 5
        NATIONAL_PHASE_PAR_TYPES = {
          'L/2' => :par_1,
          '3' => :par_2,
          '4' => :par_2,
          '5' => :par_3,
        }.freeze

        NATIONAL_TILE_LAYS = [{ lay: true, upgrade: true, cost: 0 }].freeze
        TILE_LAYS = [
          { lay: true, upgrade: true, cost: 0 },
          { lay: true, upgrade: true, cost: 10 },
          { lay: true, upgrade: true, cost: 20 },
          { lay: true, upgrade: true, cost: 30 },
        ].freeze

        PHASE_PAR_TYPES = {
          'L/2' => :par,
          '3' => :par_1,
          '4' => :par_1,
          '5' => :par_2,
          '6' => :par_2,
          '8' => :par_3,
          '10' => :par_3,
        }.freeze

        REGION_CORPORATIONS = {
          'GREAT_BRITAIN' => %w[LNWR GWR NBR],
          'FRANCE' => %w[PLM MIDI OU],
          'GERMANY' => %w[KPS BY KHS],
          'AUSTRIA' => %w[SB BH FNR],
          'ITALY' => %w[SSFL IFT SFAI],
        }.freeze

        STOCK_TURN_TOKEN_PREFIX = 'ST'
        STOCK_TURN_TOKENS = {
          '3': 5,
          '4': 4,
          '5': 3,
          '6': 3,
          '7': 2,
        }.freeze

        # Corporations which will be able to float on which turn
        TURN_CORPORATIONS = {
          'ISR' => %w[GBN FN AHN BN SPN SWN G1 G2 G3 G4 G5 I1 I2 I3 I4 I5 LNWR GWR NBR PLM MIDI OU],
          'OR1' => %w[GBN FN AHN BN SPN SWN G1 G2 G3 G4 G5 I1 I2 I3 I4 I5 LNWR GWR NBR PLM MIDI OU KPS BY KHS
                      GL NRS],
        }.freeze

        attr_accessor :current_turn, :national_graph

        def can_run_route?(entity)
          national_corporation?(entity) || super
        end

        def check_connected(route, token)
          return if national_corporation?(route.corporation)

          super
        end

        def check_distance(route, visits)
          entity = route.corporation
          if national_corporation?(entity) && !visits_within_national_region?(entity, visits)
            raise GameError, 'Nationals can only run within its region'
          end
          if !national_corporation?(entity) && !visits_operating_rights?(entity, visits)
            raise GameError, 'The director need operating rights to operate in the selected regions'
          end

          super
        end

        def city_tokened_by?(city, entity)
          return true if national_corporation?(entity) && entity.coordinates.include?(city.hex.name)

          super
        end

        def entity_can_use_company?(entity, company)
          entity == company.owner
        end

        def format_currency(val)
          return super if (val % 1).zero?

          format('£%.1<val>f', val: val)
        end

        def graph_for_entity(entity)
          national_corporation?(entity) ? @national_graph : @graph
        end

        def init_company_abilities
          @companies.each do |company|
            next unless (ability = abilities(company, :exchange))
            next unless ability.from.include?(:par)

            exchange_corporations(ability).first.par_via_exchange = company
          end

          super
        end

        def ipo_name(entity)
          return 'Bank' if national_corporation?(entity)

          'Treasury'
        end

        def local_length
          99
        end

        def next_round!
          @round =
            case @round
            when Round::Stock
              @operating_rounds = @phase.operating_rounds
              new_operating_round
            when Round::Operating
              or_round_finished
              new_operating_round(@round.round_num + 1)
            when init_round.class
              reorder_players_isr!
              stock_round_isr
            end
        end

        def new_auction_round
          Round::Auction.new(self, [
            G1866::Step::SelectionAuction,
          ])
        end

        def num_certs(entity)
          # All players have a Stock Turn Company, this shouldnt count towards the cert limit.
          super - 1
        end

        def operating_order
          floated = @corporations.select(&:floated?)
          minor_nationals, corporations = floated.partition { |c| minor_national_corporation?(c) }

          minor_nationals + (corporations + @stock_turn_token_in_play.values.flatten).sort
        end

        # TODO: This is just a basic operating round.
        def operating_round(round_num)
          Round::Operating.new(self, [
            G1866::Step::StockTurnToken,
            G1866::Step::Track,
            G1866::Step::Token,
            Engine::Step::Route,
            G1866::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1866::Step::BuyTrain,
          ], round_num: round_num)
        end

        def par_price_str(share_price)
          row, = share_price.coordinates
          row_str = case row
                    when 0
                      'T'
                    when 1
                      'M'
                    when 2
                      'B'
                    else
                      ''
                    end
          "#{format_currency(share_price.price)}#{row_str}"
        end

        def place_home_token(corporation)
          return super unless corporation.id == 'PLM'
          return if corporation.tokens.first&.used

          corporation.coordinates.each do |coord|
            hex = hex_by_id(coord)
            tile = hex&.tile
            cities = tile.cities
            city = cities.find { |c| c.reserved_by?(corporation) } || cities[0]
            token = corporation.find_token_by_type

            @log << "#{corporation.name} places a token on #{hex.name}"
            city.place_token(corporation, token)
          end
        end

        def price_movement_chart
          [
            ['Market Action', 'Movement'],
            ['ST action pass', '3 →'],
            ['ST action sell (with no buy)', '2 →'],
            ['ST action buy', '1 →'],
            ['ST action sell and buy', 'none'],
            ['Dividend 0', '1 ←'],
            ['Dividend > 0', 'none'],
            ['Dividend ≥ stock value', '1 →'],
            ['Dividend ≥ 2× stock value', '2 →'],
            ['Dividend ≥ 3× stock value', '3 →'],
            ['Sale made by director', '1 ←'],
            ['Sale made by non-director, or for each loan taken', '1 ↓, or 1 ← if cannot go down'],
            ['For each loan repaid', '1 ↑, or 1 → and 1 ↓ if cannot go up'],
          ]
        end

        def reservation_corporations
          @corporations.reject { |c| national_corporation?(c) }
        end

        def round_description(name, round_number = nil)
          round_number ||= @round.round_num
          "#{name} Round #{round_number}"
        end

        def setup
          @stock_turn_token_per_player = self.class::STOCK_TURN_TOKENS[@players.size.to_s]
          @stock_turn_token_in_play = {}
          @player_setup_order = @players.dup
          @player_setup_order.each_with_index do |player, index|
            @log << "#{player.name} have stock turn tokens with number #{index + 1}"
            @stock_turn_token_in_play[player] = []
          end

          @red_reservation_entity = corporation_by_id('R')
          @corporations.delete(@red_reservation_entity)

          @current_turn = 'ISR'

          # Setup the nationals graph
          @national_graph = Graph.new(self, home_as_token: true, no_blocking: true)

          # Setup the nationals infinite trains
          self.class::NATIONAL_CORPORATIONS.each_with_index do |national, index|
            train = train_by_id("INF-#{index}")
            @depot.remove_train(train)
            train.buyable = false
            train.instance_variable_set(:@local, true)

            corporation = corporation_by_id(national)
            train.owner = corporation
            corporation.trains << train
          end

          # Randomize and setup the corporations
          setup_corporations

          # Give all players stock turn token and remove unused
          setup_stock_turn_token
        end

        def sorted_corporations
          turn_corporations = self.class::TURN_CORPORATIONS[@current_turn]
          ipoed, others = if turn_corporations
                            @corporations.select { |c| turn_corporations.include?(c.name) }.partition(&:ipoed)
                          else
                            @corporations.partition(&:ipoed)
                          end
          # Remove floated minor nationals
          ipoed.reject! { |c| minor_national_corporation?(c) }
          ipoed.sort + others
        end

        def tile_lays(entity)
          return self.class::NATIONAL_TILE_LAYS if national_corporation?(entity)

          self.class::TILE_LAYS
        end

        def train_help(_entity, runnable_trains, _routes)
          return [] if runnable_trains.empty?

          entity = runnable_trains[0].owner

          help = []
          if runnable_trains.any? { |t| self.class::LOCAL_TRAIN == t.name }
            help << "L (local) trains run in a city which has a #{entity.name} token. "\
                    'They can additionally run to a single small station, but are not required to do so. '\
                    'They can thus be considered 1 (+1) trains. '\
                    'Only one L train may operate on each station token.'
          end

          if national_corporation?(entity)
            help << 'Nationals run a hypothetical train of infinite length, within its national boundaries. '\
                    'This train is allowed to run a route of just a single city.'
          end
          help
        end

        def upgrade_cost(_tile, _hex, entity, _spender)
          return 0 if national_corporation?(entity)

          super
        end

        def hex_operating_rights?(entity, hex)
          nationals = operating_rights(entity)
          nationals.any? { |national| self.class::NATIONAL_REGION_HEXES[national].include?(hex.name) }
        end

        def hex_within_national_region?(entity, hex)
          self.class::NATIONAL_REGION_HEXES[entity.id].include?(hex.name)
        end

        def major_national_corporation?(corporation)
          return false unless corporation

          corporation.type == :national
        end

        def minor_national_corporation?(corporation)
          return false unless corporation

          corporation.type == :minor_national
        end

        def operating_rights(entity)
          player = entity.owner
          national_shares = player.shares_by_corporation.select { |c, s| national_corporation?(c) && !s.empty? }

          operating_rights = self.class::CORPORATIONS_OPERATING_RIGHTS[entity.id]
          (national_shares.keys.map(&:id) + Array(operating_rights)).uniq
        end

        def national_corporation?(corporation)
          minor_national_corporation?(corporation) || major_national_corporation?(corporation)
        end

        def phase_par_type(corp)
          return self.class::NATIONAL_PHASE_PAR_TYPES[@phase.name] if national_corporation?(corp)

          self.class::PHASE_PAR_TYPES[@phase.name]
        end

        def place_starting_token(corporation, token, hex_coordinates)
          hex = hex_by_id(hex_coordinates)
          city = hex.tile.cities.first
          city.place_token(corporation, token, free: true, check_tokenable: false)
        end

        def purchase_stock_turn_token(player, share_price)
          index = @player_setup_order.find_index(player)
          corporation = Corporation.new(
            sym: 'ST',
            name: 'Stock Turn Token',
            logo: "1866/#{index + 1}",
            tokens: [],
            type: 'stock_turn_corporation',
            float_percent: 100,
            max_ownership_percent: 100,
            shares: [100],
            always_market_price: true,
            color: 'black',
            text_color: 'white',
            reservation_color: nil,
            capitalization: self.class::CAPITALIZATION,
          )
          corporation.owner = player

          @stock_market.set_par(corporation, share_price)
          player.spend(share_price.price, @bank)
          @stock_turn_token_in_play[player] << corporation
          @log << "#{player.name} buys a stock turn token at #{format_currency(share_price.price)}"
        end

        def reorder_players_isr!
          current_order = @players.dup

          # Sort on least amount of money
          @players.sort_by! { |p| [p.cash, current_order.index(p)] }

          # The player holding the P1 will become priority dealer
          p1 = @companies.find { |c| c.id == 'P1' }
          if p1
            @players.delete(p1.owner)
            @players.unshift(p1.owner)
            p1.close!
            @log << "#{p1.name} closes"
          end
          @log << "-- Priority order: #{@players.map(&:name).join(', ')}"
        end

        def setup_corporations
          # Randomize from preset seed to get same order
          corps = @corporations.select { |c| c.type == :public_5 }.sort_by { rand }
          @removed_corporations = []

          # Select one of the three public companies based in each of GB, France, A-H, Germany & Italy
          starting_corps = []
          self.class::REGION_CORPORATIONS.each do |_, v|
            corp = corps.find { |c| v.include?(c.name) }
            starting_corps << corp
            corps.delete(corp)
          end

          # Include the next 8 corporations in the game, remove the last 7.
          corps.each_with_index do |c, index|
            if index < 8
              starting_corps << c
            else
              @removed_corporations << c
              @corporations.delete(c)
            end
          end

          # Put down the home tokens of all the removed corporations
          @removed_corporations.each do |corp|
            Array(corp.coordinates).each do |coord|
              token = Engine::Token.new(corp, logo: "/logos/1866/#{corp.name}_REMOVED.svg",
                                              simple_logo: "/logos/1866/#{corp.name}_REMOVED.svg",
                                              type: :removed)

              place_starting_token(corp, token, coord)
            end
            @log << "#{corp.name} - #{corp.full_name} is removed from the game"
          end
        end

        def setup_stock_turn_token
          # Give each player a stock turn company
          @players.each_with_index do |player, index|
            company = @companies.find { |c| c.id == "#{self.class::STOCK_TURN_TOKEN_PREFIX}#{index + 1}" }
            company.owner = player
            player.companies << company
          end

          # Remove the unused stock turn companies
          @companies.dup.each do |company|
            next if !stock_turn_token_company?(company) || company.owner

            @companies.delete(company)
          end
        end

        def stock_round_isr
          @log << '-- Initial Stock Round --'
          @round_counter += 1
          Round::Stock.new(self, [
            G1866::Step::BuySellParShares,
          ])
        end

        def stock_turn_corporation?(corporation)
          return false unless corporation

          corporation.type == :stock_turn_corporation
        end

        def stock_turn_token_company?(company)
          company.id[0..1] == self.class::STOCK_TURN_TOKEN_PREFIX
        end

        def visits_operating_rights?(entity, visits)
          nationals = operating_rights(entity)

          count = visits.count do |v|
            nationals.any? { |national| self.class::NATIONAL_REGION_HEXES[national].include?(v.hex.name) }
          end

          count == visits.size
        end

        def visits_within_national_region?(entity, visits)
          hexes = self.class::NATIONAL_REGION_HEXES[entity.id]
          visits.count { |v| hexes.include?(v.hex.name) } == visits.size
        end
      end
    end
  end
end
