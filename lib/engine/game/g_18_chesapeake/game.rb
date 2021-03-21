# frozen_string_literal: true

require_relative 'meta'
require_relative 'share_pool'
require_relative 'round/stock'
require_relative '../base'

module Engine
  module Game
    module G18Chesapeake
      class Game < Game::Base
        include_meta(G18Chesapeake::Meta)

        register_colors(green: '#237333',
                        red: '#d81e3e',
                        blue: '#0189d1',
                        lightBlue: '#a2dced',
                        yellow: '#FFF500',
                        orange: '#f48221',
                        brown: '#7b352a')

        CURRENCY_FORMAT_STR = '$%d'

        BANK_CASH = 8000

        CERT_LIMIT = { 2 => 20, 3 => 20, 4 => 16, 5 => 13, 6 => 11 }.freeze

        STARTING_CASH = { 2 => 1200, 3 => 800, 4 => 600, 5 => 480, 6 => 400 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        # rubocop:disable Layout/LineLength
        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 2,
          '4' => 2,
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '14' => 5,
          '15' => 6,
          '16' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 3,
          '24' => 3,
          '25' => 2,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 2,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 2,
          '55' => 1,
          '56' => 1,
          '57' => 7,
          '58' => 2,
          '69' => 1,
          '70' => 1,
          '611' => 5,
          '915' => 1,
          'X1' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:0,b:_0;path=a:4,b:_0;label=DC',
          },
          'X2' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=DC',
          },
          'X3' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:2;path=a:3,b:_1;path=a:_1,b:5;label=OO',
          },
          'X4' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:1;path=a:2,b:_1;path=a:_1,b:3;label=OO',
          },
          'X5' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;path=a:3,b:_0;path=a:_0,b:5;path=a:0,b:_1;path=a:_1,b:4;label=OO',
          },
          'X6' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=DC',
          },
          'X7' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=OO',
          },
          'X8' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:100,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=DC',
          },
          'X9' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=OO',
          },
        }.freeze
        # rubocop:enable Layout/LineLength

        LOCATION_NAMES = {
          'B2' => 'Pittsburgh',
          'A7' => 'Ohio',
          'B14' => 'West Virginia Coal',
          'B4' => 'Charleroi & Connellsville',
          'C5' => 'Green Spring',
          'C13' => 'Lynchburg',
          'D2' => 'Berlin',
          'D8' => 'Leesburg',
          'D12' => 'Charlottesville',
          'E3' => 'Hagerstown',
          'E11' => 'Fredericksburg',
          'F2' => 'Harrisburg',
          'F8' => 'Washington DC',
          'G3' => 'Columbia',
          'G13' => 'Richmond',
          'H4' => 'Strasburg',
          'H6' => 'Baltimore',
          'H14' => 'Norfolk',
          'I5' => 'Wilmington',
          'I9' => 'Delmarva Peninsula',
          'J2' => 'Allentown',
          'J4' => 'Philadelphia',
          'J6' => 'Camden',
          'K1' => 'Easton',
          'K3' => 'Trenton & Amboy',
          'K5' => 'Burlington & Princeton',
          'L2' => 'New York',
        }.freeze

        MARKET = [
          %w[80 85 90 100 110 125 140 160 180 200 225 250 275 300 325 350 375],
          %w[75 80 85 90 100 110 125 140 160 180 200 225 250 275 300 325 350],
          %w[70 75 80 85 95p 105 115 130 145 160 180 200],
          %w[65 70 75 80p 85 95 105 115 130 145],
          %w[60 65 70p 75 80 85 95 105],
          %w[55y 60 65 70 75 80],
          %w[50y 55y 60 65],
          %w[40y 45y 50y],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
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
            name: 'D',
            on: 'D',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 80,
            rusts_on: '4',
            num: 7,
          },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6',
            num: 6,
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: 'D',
            num: 5,
          },
          {
            name: '5',
            distance: 5,
            price: 500,
            num: 3,
            events: [{ 'type' => 'close_companies' }],
          },
          { name: '6', distance: 6, price: 630, num: 2 },
          {
            name: 'D',
            distance: 999,
            price: 900,
            num: 20,
            available_on: '6',
            discount: { '4' => 200, '5' => 200, '6' => 200 },
          },
        ].freeze

        # rubocop:disable Layout/LineLength
        COMPANIES = [
          {
            name: 'Delaware and Raritan Canal',
            value: 20,
            revenue: 5,
            desc: 'No special ability. Blocks hex K3 while owned by a player.',
            sym: 'D&R',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['K3'] }],
            color: nil,
          },
          {
            name: 'Columbia - Philadelphia Railroad',
            value: 40,
            revenue: 10,
            desc: 'Blocks hexes H2 and I3 while owned by a player. The owning corporation may lay two connected tiles in hexes H2 and I3. Only #8 and #9 tiles may be used. If any tiles are played in these hexes other than by using this ability, the ability is forfeit. These tiles may be placed even if the owning corporation does not have a route to the hexes. These tiles are laid during the tile laying step and are in addition to the corporation’s tile placement action.',
            sym: 'C-P',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[H2 I3] },
                        {
                          type: 'tile_lay',
                          owner_type: 'corporation',
                          must_lay_together: true,
                          must_lay_all: true,
                          hexes: %w[H2 I3],
                          tiles: %w[8 9],
                          when: 'track',
                          count: 2,
                        }],
            color: nil,
          },
          {
            name: 'Baltimore and Susquehanna Railroad',
            value: 50,
            revenue: 10,
            desc: 'Blocks hexes F4 and G5 while owned by a player. The owning corporation may lay two connected tiles in hexes F4 and G5. Only #8 and #9 tiles may be used. If any tiles are played in these hexes other than by using this ability, the ability is forfeit. These tiles may be placed even if the owning corporation does not have a route to the hexes. These tiles are laid during the tile laying step and are in addition to the corporation’s tile placement action.',
            sym: 'B&S',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[F4 G5] },
                        {
                          type: 'tile_lay',
                          owner_type: 'corporation',
                          must_lay_together: true,
                          must_lay_all: true,
                          hexes: %w[F4 G5],
                          tiles: %w[8 9],
                          when: 'track',
                          count: 2,
                        }],
            color: nil,
          },
          {
            name: 'Chesapeake and Ohio Canal',
            value: 80,
            revenue: 15,
            desc: 'Blocks hex D2 while owned by a player. The owning corporation may place a tile in hex D2. The corporation does not need to have a route to this hex. The tile placed counts as the corporation’s tile lay action and the corporation must pay the terrain cost. The corporation may then immediately place a station token free of charge.',
            sym: 'C&OC',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['D2'] },
                        {
                          type: 'teleport',
                          owner_type: 'corporation',
                          tiles: ['57'],
                          hexes: ['D2'],
                        }],
            color: nil,
          },
          {
            name: 'Baltimore & Ohio Railroad',
            value: 100,
            revenue: 0,
            desc: 'Purchasing player immediately takes a 10% share of the B&O. This does not close the private company. This private company has no other special ability.',
            sym: 'B&OR',
            abilities: [{ type: 'shares', shares: 'B&O_1' }],
            color: nil,
          },
          {
            name: 'Cornelius Vanderbilt',
            value: 200,
            revenue: 30,
            desc: 'This private closes when the associated corporation buys its first train. It cannot be bought by a corporation.',
            sym: 'CV',
            abilities: [{ type: 'shares', shares: 'random_president' },
                        { type: 'no_buy' }],
            color: nil,
          },
        ].freeze
        # rubocop:enable Layout/LineLength

        CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'PRR',
            name: 'Pennsylvania Railroad',
            logo: '18_chesapeake/PRR',
            simple_logo: '18_chesapeake/PRR.alt',
            tokens: [0, 40, 60, 80],
            coordinates: 'F2',
            color: '#237333',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'PLE',
            name: 'Pittsburgh and Lake Erie Railroad',
            logo: '18_chesapeake/PLE',
            simple_logo: '18_chesapeake/PLE.alt',
            tokens: [0, 40, 60],
            coordinates: 'A3',
            color: :black,
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'SRR',
            name: 'Strasburg Rail Road',
            logo: '18_chesapeake/SRR',
            simple_logo: '18_chesapeake/SRR.alt',
            tokens: [0, 40],
            coordinates: 'H4',
            color: '#d81e3e',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'B&O',
            name: 'Baltimore & Ohio Railroad',
            logo: '18_chesapeake/BO',
            simple_logo: '18_chesapeake/BO.alt',
            tokens: [0, 40, 60],
            coordinates: 'H6',
            city: 0,
            color: '#0189d1',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'C&O',
            name: 'Chesapeake & Ohio Railroad',
            logo: '18_chesapeake/CO',
            simple_logo: '18_chesapeake/CO.alt',
            tokens: [0, 40, 60, 80],
            coordinates: 'G13',
            color: '#a2dced',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'LV',
            name: 'Lehigh Valley Railroad',
            logo: '18_chesapeake/LV',
            simple_logo: '18_chesapeake/LV.alt',
            tokens: [0, 40],
            coordinates: 'J2',
            color: '#FFF500',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'C&A',
            name: 'Camden & Amboy Railroad',
            logo: '18_chesapeake/CA',
            simple_logo: '18_chesapeake/CA.alt',
            tokens: [0, 40],
            coordinates: 'J6',
            color: '#f48221',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'N&W',
            name: 'Norfolk & Western Railway',
            logo: '18_chesapeake/NW',
            simple_logo: '18_chesapeake/NW.alt',
            tokens: [0, 40, 60],
            coordinates: 'C13',
            color: '#7b352a',
            reservation_color: nil,
          },
        ].freeze

        # rubocop:disable Layout/LineLength
        HEXES = {
          white: {
            %w[B6 B8 B10 C3 C7 C9 C11 E7 E9 E13 F6 F12 G7 I7 J8 J10 L4 F4 G5 H2 I3] => '',
            %w[B12 D4 D6 D10 E5] => 'upgrade=cost:80,terrain:mountain',
            %w[F10 G9 G11 H12] => 'upgrade=cost:40,terrain:water',
            %w[B4 K3 K5] => 'town=revenue:0;town=revenue:0',
            %w[C5 D12 E3 F2 G13 J2] => 'city=revenue:0',
            %w[C13 D2 D8] => 'city=revenue:0;upgrade=cost:80,terrain:mountain',
            ['E11'] => 'town=revenue:0',
            ['F8'] => 'city=revenue:0;label=DC',
            %w[G3 I5] => 'town=revenue:0;upgrade=cost:40,terrain:water',
            %w[H4 J6] => 'city=revenue:0;upgrade=cost:40,terrain:water',
          },
          red: {
            ['A3'] =>
                     'city=revenue:yellow_40|green_50|brown_60|gray_80,hide:1,groups:Pittsburgh;path=a:5,b:_0;border=edge:4',
            ['B2'] =>
            'offboard=revenue:yellow_40|green_50|brown_60|gray_80,groups:Pittsburgh;path=a:0,b:_0;border=edge:1',
            ['A7'] =>
            'offboard=revenue:yellow_40|green_60|brown_80|gray_100;path=a:4,b:_0;path=a:5,b:_0',
            ['A13'] =>
            'offboard=revenue:yellow_40|green_50|brown_60|gray_80,hide:1,groups:West Virginia Coal;path=a:4,b:_0;border=edge:5',
            ['B14'] =>
            'offboard=revenue:yellow_40|green_50|brown_60|gray_80,groups:West Virginia Coal;path=a:3,b:_0;path=a:4,b:_0;border=edge:2',
            ['H14'] =>
            'offboard=revenue:yellow_30|green_40|brown_50|gray_60;path=a:2,b:_0',
            ['L2'] =>
            'offboard=revenue:yellow_40|green_60|brown_80|gray_100;path=a:0,b:_0;path=a:1,b:_0',
          },
          gray: {
            ['E1'] => 'path=a:1,b:5',
            ['F14'] => 'path=a:3,b:4',
            ['G1'] => 'path=a:1,b:5;path=a:0,b:1',
            ['I9'] => 'town=revenue:30;path=a:3,b:_0;path=a:_0,b:5',
            ['K1'] => 'town=revenue:30;path=a:0,b:_0;path=a:_0,b:1',
            ['K7'] => 'path=a:2,b:3',
          },
          yellow: {
            ['H6'] =>
                     'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:4,b:_1;label=OO;upgrade=cost:40,terrain:water',
            ['J4'] =>
            'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:3,b:_1;label=OO',
          },
        }.freeze
        # rubocop:enable Layout/LineLength

        LAYOUT = :flat

        MUST_BID_INCREMENT_MULTIPLE = true
        ONLY_HIGHEST_BID_COMMITTED = true
        SELL_BUY_ORDER = :sell_buy

        def init_share_pool
          G18Chesapeake::SharePool.new(self)
        end

        def preprocess_action(action)
          case action
          when Action::LayTile
            queue_log! do
              check_special_tile_lay(action, baltimore)
              check_special_tile_lay(action, columbia)
            end
          end
        end

        def action_processed(action)
          case action
          when Action::LayTile
            flush_log!
          end
        end

        def stock_round
          G18Chesapeake::Round::Stock.new(self, [
            Step::DiscardTrain,
            Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Step::Bankrupt,
            Step::SpecialTrack,
            Step::SpecialToken,
            Step::BuyCompany,
            Step::Track,
            Step::Token,
            Step::Route,
            Step::Dividend,
            Step::DiscardTrain,
            Step::BuyTrain,
            [Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def setup
          cornelius.add_ability(Ability::Close.new(
            type: :close,
            when: 'bought_train',
            corporation: abilities(cornelius, :shares).shares.first.corporation.name,
          ))

          return unless two_player?

          cv_corporation = abilities(cornelius, :shares).shares.first.corporation

          @corporations.each do |corporation|
            next if corporation == cv_corporation

            presidents_share = corporation.shares_by_corporation[corporation].first
            presidents_share.percent = 30

            final_share = corporation.shares_by_corporation[corporation].last
            @share_pool.transfer_shares(final_share.to_bundle, @bank)
          end
        end

        def status_str(corp)
          return unless two_player?

          "#{corp.presidents_percent}% President's Share"
        end

        def timeline
          @timeline = [
            'At the end of each set of ORs the next available non-permanent (2, 3 or 4) train will be exported
           (removed, triggering phase change as if purchased)',
          ]
        end

        def check_special_tile_lay(action, company)
          abilities(company, :tile_lay, time: 'any') do |ability|
            hexes = ability.hexes
            next unless hexes.include?(action.hex.id)
            next if company.closed? || action.entity == company

            company.remove_ability(ability)
            @log << "#{company.name} loses the ability to lay #{hexes}"
          end
        end

        def columbia
          @companies.find { |company| company.name == 'Columbia - Philadelphia Railroad' }
        end

        def baltimore
          @companies.find { |company| company.name == 'Baltimore and Susquehanna Railroad' }
        end

        def cornelius
          @cornelius ||= @companies.find { |company| company.name == 'Cornelius Vanderbilt' }
        end

        def or_set_finished
          depot.export! if %w[2 3 4].include?(@depot.upcoming.first.name)
        end

        def float_corporation(corporation)
          super

          return unless two_player?

          @log << "#{corporation.name}'s remaining shares are transferred to the Market"
          bundle = ShareBundle.new(corporation.shares_of(corporation))
          @share_pool.transfer_shares(bundle, @share_pool)
        end
      end
    end
  end
end
