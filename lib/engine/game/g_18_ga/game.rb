# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative '../company_price_50_to_150_percent'
require_relative '../cities_plus_towns_route_distance_str'

module Engine
  module Game
    module G18GA
      class Game < Game::Base
        include_meta(G18GA::Meta)
        include CitiesPlusTownsRouteDistanceStr

        CURRENCY_FORMAT_STR = '$%d'

        BANK_CASH = 8000

        CERT_LIMIT = { 3 => 15, 4 => 12, 5 => 10 }.freeze

        STARTING_CASH = { 3 => 600, 4 => 450, 5 => 360 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        TILES = {
          '3' => 3,
          '4' => 3,
          '5' => 2,
          '6' => 2,
          '7' => 5,
          '8' => 11,
          '9' => 10,
          '57' => 4,
          '58' => 3,
          '451a' => 1,
          '14' => 4,
          '15' => 4,
          '16' => 1,
          '17' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 4,
          '24' => 4,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 2,
          '29' => 2,
          '141' => 2,
          '142' => 2,
          '143' => 2,
          '452a' => 1,
          '453a' => 1,
          '454a' => 1,
          '39' => 2,
          '40' => 1,
          '41' => 3,
          '42' => 3,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '63' => 4,
          '70' => 1,
          '455a' => 1,
          '456a' => 1,
          '457a' => 1,
          '458a' => 1,
          '459a' => 1,
        }.freeze

        LOCATION_NAMES = {
          'I11' => 'Brunswick',
          'C3' => 'Rome',
          'D4' => 'Atlanta',
          'D10' => 'Augusta',
          'E7' => 'Milledgeville',
          'F6' => 'Macon',
          'G3' => 'Columbus',
          'H4' => 'Albany',
          'I9' => 'Waycross',
          'J12' => 'Jacksonville',
          'E1' => 'Montgomery',
          'J4' => 'Tallahassee',
          'A3' => 'Chattanooga',
          'B10' => 'Greeneville',
          'G13' => 'Savannah',
          'G11' => 'Statesboro',
          'I7' => 'Valdosta',
        }.freeze

        MARKET = [
          %w[60
             70
             80
             90
             100
             110p
             120
             135
             150
             170
             190
             210
             230
             250
             275
             300e],
          %w[55
             60
             70
             80
             90p
             100
             110
             120
             135
             150
             170
             190
             210
             230
             250],
          %w[50y
             55
             60
             70p
             80
             90
             100
             110
             120
             135
             150
             170
             190],
          %w[45y 50y 55p 60 70 80 90 100 110 120 135],
          %w[40y 45y 50y 55 60 70 80 90],
          %w[35y 40y 45y 50y 55y],
          %w[30y 35y 40y 45y 50y],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
            status: %w[can_buy_companies_from_other_players limited_train_buy],
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies
                       can_buy_companies_from_other_players
                       limited_train_buy],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies can_buy_companies_from_other_players],
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 100,
            rusts_on: '4',
            num: 6,
          },
          {
            name: '3',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 180,
            rusts_on: '6',
            num: 4,
          },
          {
            name: '4',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 300,
            rusts_on: '8',
            num: 3,
          },
          {
            name: '5',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 450,
            num: 2,
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '6',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 630,
            num: 2,
          },
          {
            name: '8',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 8, 'visit' => 8 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 800,
            num: 5,
          },
        ].freeze

        COMPANIES = [
          {
            name: 'Lexington Terminal RR',
            value: 20,
            revenue: 5,
            desc: 'No special ability.',
            sym: 'LTR',
          },
          {
            name: 'Midland Railroad Co.',
            value: 40,
            revenue: 10,
            desc: 'Blocks hex F12 while owned by a player. A corporation that owns the Midland may '\
                  'lay a tile in the Midland\'s hex for free, once. The tile need not be connected '\
                  'to an existing station of the corporation. The corporation need not pay the $40 '\
                  'cost of the swamp. And it does not count as the corporation\'s one tile lay per '\
                  'turn. (But it still must be laid during the tile-laying step of the corporation\'s '\
                  'turn, and it must not dead-end into a blank side of a red or gray hex, or off the '\
                  'map.) This action does not close the Midland.',
            sym: 'MRC',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['F12'] },
                        {
                          type: 'tile_lay',
                          free: true,
                          count: 1,
                          owner_type: 'corporation',
                          hexes: ['F12'],
                          tiles: %w[7 8 9],
                          when: 'track',
                        }],
          },
          {
            name: 'Waycross & Southern RR',
            value: 70,
            revenue: 15,
            desc: 'A corporation that owns the Waycross & Southern may place a station token in '\
                  'Waycross at no cost, if there is room. The corporation need not connect to Waycross '\
                  'to use this special ability. However, it can only be done during the token-placement '\
                  'step of the corporation\'s turn, and only if the corporation has a token left, and it '\
                  'counts as the corporation\'s one station placement allowed per turn (excluding the home '\
                  'station). This action does not close the Waycross & Southern. As an exception to rule '\
                  '4.2.1(k), any corporation is free to lay tiles in the Waycross hex even if the Waycross '\
                  '& Southern is still owned by a player. ',
            sym: 'W&SR',
            abilities: [
              {
                type: 'token',
                owner_type: 'corporation',
                hexes: ['I9'],
                price: 0,
                teleport_price: 0,
                count: 1,
                from_owner: true,
              },
            ],
          },
          {
            name: 'Ocilla Southern RR',
            value: 100,
            revenue: 20,
            desc: 'Block hex G7 while owned by a player. When a Corporation purchases the Ocilla '\
                  'Southern, the corporation immediately gets the 2 Train marked Free (unless a 4 Train '\
                  'has been purchased or the corporation already has four trains, in which case the free '\
                  'train is removed from play). This acquisition is not considered a train purchase '\
                  '(so it does not prevent the corporation from also purchasing a train on the same turn), '\
                  'and does not close the Ocilla Southern. The free train cannot be sold to another '\
                  'corporation. In all other respects it is a normal 2 Train. ',
            sym: 'OSR',
            abilities: [
              {
                type: 'blocks_hexes',
                owner_type: 'player',
                hexes: ['G7'],
              },
            ],
          },
          {
            name: 'Macon & Birmingham RR',
            value: 150,
            revenue: 25,
            desc: 'Block hex F4 while owned by a player. Purchasing player immediately takes a 10% '\
                  'share of the Central of Georgia. This does not close the private company. This private '\
                  'company has no other special ability. ',
            sym: 'M&BR',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['F4'] },
                        { type: 'shares', shares: 'CoG_1' }],
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'ACL',
            name: 'Atlantic Coast Line',
            logo: '18_ga/ACL',
            simple_logo: '18_ga/ACL.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'J12',
            color: 'black',
          },
          {
            float_percent: 60,
            sym: 'CoG',
            name: 'Central of Georgia Railroad',
            logo: '18_ga/CoG',
            simple_logo: '18_ga/CoG.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'F6',
            color: 'red',
          },
          {
            float_percent: 60,
            sym: 'G&F',
            name: 'Georgia and Florida Railroad',
            logo: '18_ga/GF',
            simple_logo: '18_ga/GF.alt',
            tokens: [0, 40],
            coordinates: 'H4',
            color: 'deepskyblue',
            text_color: 'black',
          },
          {
            float_percent: 60,
            sym: 'GA',
            name: 'Georgia Railroad',
            logo: '18_ga/GA',
            simple_logo: '18_ga/GA.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'D10',
            city: 0,
            color: 'green',
          },
          {
            float_percent: 60,
            sym: 'W&A',
            name: 'Western and Atlantic Railroad',
            logo: '18_ga/WA',
            simple_logo: '18_ga/WA.alt',
            tokens: [0, 40],
            coordinates: 'D4',
            color: 'purple',
          },
          {
            float_percent: 60,
            sym: 'SAL',
            name: 'Seaboard Air Line',
            logo: '18_ga/SAL',
            simple_logo: '18_ga/SAL.alt',
            tokens: [0, 40, 100],
            coordinates: 'G13',
            color: 'gold',
            text_color: 'black',
          },
        ].freeze

        HEXES = {
          white: {
            %w[B4
               C7
               C9
               D2
               D6
               D8
               E5
               E9
               F4
               F10
               G1
               G5
               G7
               H6
               H8
               I5
               J6
               J8
               E11] => '',
            %w[C5 F8 G9 H10 H12] => 'upgrade=cost:20,terrain:water',
            %w[E3 F2 F12 H2 I3 J10] => 'upgrade=cost:40,terrain:water',
            %w[B2 B6 B8 C1] => 'upgrade=cost:60,terrain:water',
            ['D4'] => 'city=revenue:0;city=revenue:0;city=revenue:0;label=ATL;',
            %w[I11 C3 D10 F6 G3 H4 I9 G13] => 'city=revenue:0',
            %w[G11 I7] => 'town=revenue:0',
            ['E7'] => 'town=revenue:0;upgrade=cost:20,terrain:water',
          },
          red: {
            ['J12'] => 'city=revenue:yellow_30|brown_60;path=a:1,b:_0;path=a:2,b:_0',
            ['A3'] => 'offboard=revenue:yellow_30|brown_60;path=a:0,b:_0;path=a:5,b:_0',
            ['B10'] => 'offboard=revenue:yellow_30|brown_40;path=a:0,b:_0;path=a:1,b:_0',
          },
          gray: {
            ['E1'] =>
                     'city=revenue:yellow_30|brown_40;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['J4'] =>
            'city=revenue:yellow_20|brown_50;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
        }.freeze

        LAYOUT = :pointy

        GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_or, bank: :current_or }.freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'can_buy_companies_from_other_players' => ['Interplayer Company Buy',
                                                     'Companies can be bought between players']
        ).merge(
          Engine::Step::SingleDepotTrainBuy::STATUS_TEXT
        ).freeze

        STANDARD_YELLOW_CITY_TILES = %w[5 6 57].freeze
        STANDARD_GREEN_CITY_TILES = %w[14 15].freeze

        def p2_company
          @p2_company ||= company_by_id('MRC')
        end

        def p3_company
          @p3_company ||= company_by_id('W&SR')
        end

        def waycross_hex
          @waycross_hex ||= @hexes.find { |h| h.name == 'I9' }
        end

        include CompanyPrice50To150Percent

        def setup
          setup_company_price_50_to_150_percent

          @recently_floated = []
          make_train_soft_rust if @optional_rules&.include?(:soft_rust_4t)

          # Place neutral tokens in the off board cities
          neutral = Corporation.new(
            sym: 'N',
            name: 'Neutral',
            logo: 'open_city',
            simple_logo: 'open_city',
            tokens: [0, 0],
          )
          neutral.owner = @bank

          neutral.tokens.each { |token| token.type = :neutral }

          city_by_id('E1-0-0').place_token(neutral, neutral.next_token)
          city_by_id('J4-0-0').place_token(neutral, neutral.next_token)

          # Remember specific tiles for upgrades check later
          @green_aug_tile ||= @tiles.find { |t| t.name == '453a' }
          @green_s_tile ||= @tiles.find { |t| t.name == '454a' }
          @brown_b_tile ||= @tiles.find { |t| t.name == '457a' }
          @brown_m_tile ||= @tiles.find { |t| t.name == '458a' }

          # The last 2 train will be used as free train for a private
          # Store it in neutral corporation in the meantime
          @free_2_train = train_by_id('2-5')
          @free_2_train.buyable = false
          buy_train(neutral, @free_2_train, :free)
        end

        def tile_lays(entity)
          return super if !@optional_rules&.include?(:double_yellow_first_or) ||
            !@recently_floated&.include?(entity)

          [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }]
        end

        # Only buy and sell par shares is possible action during SR
        def stock_round
          Round::Stock.new(self, [
            Engine::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            G18GA::Step::SpecialToken,
            G18GA::Step::BuyCompany,
            Engine::Step::HomeToken,
            Engine::Step::SpecialTrack,
            Engine::Step::Track,
            G18GA::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::SingleDepotTrainBuy,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def or_round_finished
          @recently_floated = []
        end

        def float_corporation(corporation)
          @recently_floated << corporation

          super
        end

        def upgrades_to?(from, to, _special = false, selected_company: nil)
          # Augusta (D10) use standard tiles for yellow, and special tile for green
          return to.name == '453a' if from.color == :yellow && from.hex.name == 'D10'

          # Savannah (G13) use standard tiles for yellow, and special tile for green
          return to.name == '454a' if from.color == :yellow && from.hex.name == 'G13'

          # Brunswick (I11) use standard tiles for yellow/green, and special tile for brown
          return to.name == '457a' if from.color == :green && from.hex.name == 'I11'

          # Macon (F6) use standard tiles for yellow/green, and special tile for brown
          return to.name == '458a' if from.color == :green && from.hex.name == 'F6'

          super
        end

        def all_potential_upgrades(tile, tile_manifest: false, selected_company: nil)
          upgrades = super

          return upgrades unless tile_manifest

          upgrades |= [@green_aug_tile] if @green_aug_tile && STANDARD_YELLOW_CITY_TILES.include?(tile.name)
          upgrades |= [@green_s_tile] if @green_s_tile && STANDARD_YELLOW_CITY_TILES.include?(tile.name)
          upgrades |= [@brown_b_tile] if @brown_b_tile && STANDARD_GREEN_CITY_TILES.include?(tile.name)
          upgrades |= [@brown_m_tile] if @brown_m_tile && STANDARD_GREEN_CITY_TILES.include?(tile.name)

          upgrades
        end

        def add_free_two_train(corporation)
          @free_2_train.buyable = true
          buy_train(corporation, @free_2_train, :free)
          @free_2_train.buyable = false
          @log << "#{corporation.name} receives a bonus non sellable 2 train"
        end

        def make_train_soft_rust
          @depot.trains.select { |t| t.name == '4' }.each { |t| update_end_of_life(t, nil, t.rusts_on) }
        end

        def update_end_of_life(t, rusts_on, obsolete_on)
          t.rusts_on = rusts_on
          t.obsolete_on = obsolete_on
          t.variants.each { |_, v| v.merge!(rusts_on: rusts_on, obsolete_on: obsolete_on) }
        end
      end
    end
  end
end
