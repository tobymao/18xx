# frozen_string_literal: true

require_relative 'meta'
#require_relative 'stock_market'
require_relative '../base'

module Engine
  module Game
    module G18NE
      class Game < Game::Base
      # class Game < G1867::Game
        include_meta(G18NE::Meta)

        register_colors(black: '#16190e',
                        blue: '#0189d1',
                        brown: '#7b352a',
                        gray: '#7c7b8c',
                        green: '#3c7b5c',
                        olive: '#808000',
                        lightGreen: '#009a54ff',
                        lightBlue: '#4cb5d2',
                        lightishBlue: '#0097df',
                        teal: '#009595',
                        orange: '#d75500',
                        magenta: '#d30869',
                        purple: '#772282',
                        red: '#ef4223',
                        rose: '#b7274c',
                        coral: '#f3716d',
                        white: '#fff36b',
                        navy: '#000080',
                        cream: '#fffdd0',
                        yellow: '#ffdea8')

        CURRENCY_FORMAT_STR = '$%d'

        BANK_CASH = 12_000

        CERT_LIMIT = { 3 => 20, 4 => 16, 5 => 13}.freeze

        STARTING_CASH = { 3 => 400, 4 => 280, 5 => 280}.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false

        TILES = {
          '3': 5,
          '4': 5,
          '6': 8,
          '7': 5,
          '8': 18,
          '9': 15,
          '58': 5,
          '14': 4,
          '15': 4,
          '16': 2,
          '19': 2,
          '20': 2,
          '23': 5,
          '24': 5,
          '25': 4,
          '26': 2,
          '27': 2,
          '28': 2,
          '29': 2,
          '30': 2,
          '31': 2,
          '87': 4,
          '88': 4,
          '204': 4,
          '207': 1,
          '619': 4,
          '622': 1,
          '39': 2,
          '40': 2,
          '41': 2,
          '42': 2,
          '43': 2,
          '44': 2,
          '45': 2,
          '46': 2,
          '47': 2,
          '63': 7,
          '70': 2,
          '611': 3,
          '216': 2,
          '911': 4
        }.freeze

        LOCATION_NAMES = {
          'B12': 'Campbell Hall',
          'B2': 'Syracuse',
          'C3': 'Albany',
          'C5': 'Hudson',
          'C9': 'Rhinecliff',
          'C11': 'Poughkeepsie',
          'C17': 'White Plains',
          'C19': 'New York',
          'D4': 'New Lebanon',
          'E13': 'Danbury',
          'E15': 'Stamford',
          'F2': 'Burlington',
          'F4': 'Pittsfield',
          'F14': 'Bridgeport',
          'G11': 'Middletown',
          'G13': 'New Haven',
          'H4': 'Greenfield',
          'H6': 'Northampton',
          'H8': 'Springfield',
          'H10': 'Hartford',
          'H14': 'Saybrook',
          'I13': 'New London',
          'J6': 'Worcester',
          'J14': 'Westerly',
          'K1': 'New Hampshire',
          'K3': 'Fitchburg',
          'K5': 'Leominster',
          'L4': 'Lowell and Wilmington',
          'L8': 'Woonsocket',
          'L10': 'Providence',
          'M1': 'Portland',
          'M5': 'Boston',
          'M7': 'Quincy',
          'O11': 'Cape Cod'
        }.freeze

        MARKET = [
          %w[35
             40
             45
             50
             55
             60
             65
             70
             80
             90
             100p
             110p
             120p
             130p
             145p
             160p
             180p
             200p
             220
             240
             260
             280
             310
             340
             380
             420
             460
             500],
           ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: '4',
            tiles: %i[ yellow ],
            operating_rounds: 2
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[ yellow green ],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[ yellow green ],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5E',
            train_limit: 3,
            tiles: %i[ yellow green brown ],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6E',
            train_limit: 2,
            tiles: %i[ yellow green brown ],
            operating_rounds: 2,
          },
          {
            name: '8',
            on: '8E',
            train_limit: 2,
            tiles: %i[ yellow green brown gray ],
            operating_rounds: 2,
          },
          #    status: ['can_buy_companies'],
          #    status: %w[can_buy_companies export_train],
          #    status: %w[can_buy_companies export_train],
        ].freeze

        TRAINS = [
          {
            name: "2",
            distance: 2,
            price: 100,
            rusts_on: '4',
            num: 10,
          },
          {
            name: "3",
            distance: 3,
            price: 180,
            rusts_on: "6E",
            num: 7,
          },
          {
            name: "4",
            distance: 4,
            price: 300,
            rusts_on: "8E",
            num: 4,
          },
          {
            name: "5E",
            distance: 5,
            price: 500,
            num: 4,
          },
          {
            name: "6E",
            distance: 6,
            price: 600,
            num: 3
          },
          {
            name: "8E",
            distance: 8,
            price: 800,
            num: 20
          }
        ].freeze

        COMPANIES = [
          {
            name: 'Takamatsu E-Railroad',
            value: 20,
            revenue: 5,
            desc: 'Blocks Takamatsu (K4) while owned by a player.',
            sym: 'TR',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['K4'] }],
            color: nil,
          },
          {
            name: 'Mitsubishi Ferry',
            value: 30,
            revenue: 5,
            desc: 'Player owner may place the port tile on a coastal town (B11,'\
                  ' G10, I12, or J9) without a tile on it already, outside of '\
                  'the operating rounds of a corporation controlled by another '\
                  'player. The player need not control a corporation or have '\
                  'connectivity to the placed tile from one of their '\
                  'corporations. This does not close the company.',
            sym: 'MF',
            abilities: [
              {
                type: 'tile_lay',
                when: %w[stock_round owning_player_or_turn or_between_turns],
                hexes: %w[B11 G10 I12 J9],
                tiles: ['437'],
                owner_type: 'player',
                count: 1,
              },
            ],
            color: nil,
          },
          {
            name: 'Ehime Railway',
            value: 40,
            revenue: 10,
            desc: 'When this company is sold to a corporation, the selling '\
                  'player may immediately place a green tile on Ohzu (C4), '\
                  'in addition to any tile which it may lay during the same '\
                  'operating round. This does not close the company. Blocks '\
                  'C4 while owned by a player.',
            sym: 'ER',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['C4'] },
                        {
                          type: 'tile_lay',
                          hexes: ['C4'],
                          tiles: %w[12 13 14 15 205 206],
                          when: 'sold',
                          owner_type: 'corporation',
                          count: 1,
                        }],
            color: nil,
          },
          {
            name: 'Sumitomo Mines Railway',
            value: 50,
            revenue: 15,
            desc: 'Owning corporation may ignore building cost for mountain '\
                  'hexes which do not also contain rivers. This does not close '\
                  'the company.',
            sym: 'SMR',
            abilities: [
              {
                type: 'tile_discount',
                discount: 80,
                terrain: 'mountain',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Dougo Railway',
            value: 60,
            revenue: 15,
            desc: 'Owning player may exchange this private company for a 10% '\
                  'share of Iyo Railway from the initial offering.',
            sym: 'DR',
            abilities: [
              {
                type: 'exchange',
                corporations: ['IR'],
                owner_type: 'player',
                when: 'any',
                from: 'ipo',
              },
            ],
            color: nil,
          },
          {
            name: 'South Iyo Railway',
            value: 80,
            revenue: 20,
            desc: 'No special abilities.',
            sym: 'SIR',
            min_players: 3,
            color: nil,
          },
          {
            name: 'Uno-Takamatsu Ferry',
            value: 150,
            revenue: 30,
            desc: 'Does not close while owned by a player. If owned by a player '\
                  'when the first 5-train is purchased it may no longer be sold '\
                  'to a public company and the revenue is increased to 50.',
            sym: 'UTF',
            min_players: 4,
            abilities: [{ type: 'close', on_phase: 'never', owner_type: 'player' },
                        {
                          type: 'revenue_change',
                          revenue: 50,
                          on_phase: '5',
                          owner_type: 'player',
                        }],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 50,
            sym: 'AR',
            name: 'Awa Railroad',
            logo: '1889/AR',
            simple_logo: '1889/AR.alt',
            tokens: [0, 40],
            coordinates: 'K8',
            color: '#37383a',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'IR',
            name: 'Iyo Railway',
            logo: '1889/IR',
            simple_logo: '1889/IR.alt',
            tokens: [0, 40],
            coordinates: 'E2',
            color: '#f48221',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'SR',
            name: 'Sanuki Railway',
            logo: '1889/SR',
            simple_logo: '1889/SR.alt',
            tokens: [0, 40],
            coordinates: 'I2',
            color: '#76a042',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'KO',
            name: 'Takamatsu & Kotohira Electric Railway',
            logo: '1889/KO',
            simple_logo: '1889/KO.alt',
            tokens: [0, 40],
            coordinates: 'K4',
            color: '#d81e3e',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'TR',
            name: 'Tosa Electric Railway',
            logo: '1889/TR',
            simple_logo: '1889/TR.alt',
            tokens: [0, 40, 40],
            coordinates: 'F9',
            color: '#00a993',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'KU',
            name: 'Tosa Kuroshio Railway',
            logo: '1889/KU',
            simple_logo: '1889/KU.alt',
            tokens: [0],
            coordinates: 'C10',
            color: '#0189d1',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'UR',
            name: 'Uwajima Railway',
            logo: '1889/UR',
            simple_logo: '1889/UR.alt',
            tokens: [0, 40, 40],
            coordinates: 'B7',
            color: '#7b352a',
            reservation_color: nil,
          },
        ].freeze

        # rubocop:disable Layout/LineLength
        HEXES = {
          white: {
            %w[ B16 B6 C13 D10 D12 D14 D16 D2 D6 D8 E3 G3 G7 G9 I11 I3 I9 J10 J12 J4 J8 K11 K13 K7 L2 M11 M9 N10 N8 O9 L6] => 'blank',
            %w[ E11 E5 E7 E9 F10 F12 F6 F8 G5 I5 I7 ] => 'upgrade=cost:40,terrain:mountainr',
            %w[ B10 B14 B18 B8 C15 C7 H12 H2 K9 M3 ] => 'upgrade=cost:20,terrain:water',
            %w[ C17 C9 D4 F14 G11 H14 H6 J14 K5 L8 ] => 'town=revenue:0',
            %w[ C5 E15 F12 F4 I13 ] => 'city=revenue:0',
            %w[ B12 E13 H4 ] => 'city=revenue:0;upgrade=cost:20,terrain:water',
            %w[ M7 ] => 'town=revenue:20;city=revenue:20',
            %w[ N4] => 'town=revenue:0;upgrade=cost:20,terrain:water',
          },
          yellow: {
            %w[L10] => 'city=revenue:30;path=a:_0,b:2;path=a:_0,b:3;upgrade=cost:20,terrain:water;label=Y',
            %w[ C3 ] => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:5,b:_1;label=Y',
            %w[ C11 ] => 'city=revenue:20;path=a:_0,b:0;path=a:_0,b:3',
            %w[ G13 ] => 'city=revenue:30;city=revenue:30;city=revenue:30;path=a:_0,b:1;path=a:_1,b:3;path=a:_2,b:5;label=NH',
            %w[ H10 ] => 'city=revenue:30;path=a:_0,b:1;path=a:_0,b:2;label=H', 
            %w[ H8 ] => 'city=revenue:20;city=revenue:20;path=a:_0,b:1;path=a:_1,b:3',
            %w[ J6 ] => 'city=revenue:20;path=a:_0,b:4;path=a:_0,b:5',
            %w[ K3 ] => 'city=revenue:20;path=a:_0,b:0;path=a:_0,b:1;upgrade=cost:20,terrain:water',
            %w[ L4 ] => 'city=revenue:20;town=revenue=10',
            %w[ M5 ] => 'city=revenue:30;city=revenue:30;path=a:2,b:_0;path=a:4,b:_1;label=B',
          },
          gray: {
            %w[ A13 ] => 'path=a:4,b:5',
            %w[ B4 ] => 'path=a:4,b:5',
            %w[ A13 ] => 'path=a:4,b:5',
            %w[ E17 ] => 'path=a:2,b:3',
            %w[ G15 ] => 'path=a:2,b:3;path=a:3,b:4',
            %w[ O11] => 'town=revenue:40;path=a:2,b:_0;path=a:_0,b:3',
          },
          red: {
            %w[ B2 ] => 'offboard=revenue:yellow_0|green_20|brown_30|gray_30;path=a:5,b:_0',
            %w[ C19 ] => 'city=revenue:yellow_40|green_50|brown_70|gray_100;path=a:2,b:_0;path=a:3,b:_0',
            %w[ F2 ] => 'city=revenue:yellow_30|green_40|brown_50|gray_60;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0',
            %w[ K1 ] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_60;path=a:0,b:_0;path=a:5,b:_0',
            %w[ M1 ] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_60;path=a:0,b:_0;path=a:1,b:_0',
          },
        }.freeze
        # rubocop:enable Layout/LineLength

        LAYOUT = :flat

        HOME_TOKEN_TIMING = :float
        MUST_BID_INCREMENT_MULTIPLE = true
        MUST_BUY_TRAIN = :always # mostly true, needs custom code
        POOL_SHARE_DROP = :none
        SELL_MOVEMENT = :down_block_pres
        ALL_COMPANIES_ASSIGNABLE = true
        SELL_AFTER = :operate
        SELL_BUY_ORDER = :sell_buy
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
        GAME_END_CHECK = { bank: :current_or, custom: :one_more_full_or_set }.freeze

        CERT_LIMIT_CHANGE_ON_BANKRUPTCY = true

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'export_train' => ['Train Export to CN',
                             'At the end of each OR the next available train will be exported
                            (given to the CN, triggering phase change as if purchased)'],
        ).freeze

        # Two lays with one being an upgrade, second tile costs 20
        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: true, upgrade: :not_if_upgraded, cost: 20, cannot_reuse_same_hex: true },
        ].freeze

      end
    end
  end
end
