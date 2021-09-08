# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G18NewEngland
      class Game < Game::Base
        include_meta(G18NewEngland::Meta)

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
        CERT_LIMIT = { 3 => 20, 4 => 16, 5 => 13 }.freeze
        STARTING_CASH = { 3 => 400, 4 => 280, 5 => 280 }.freeze
        CAPITALIZATION = :incremental
        MUST_SELL_IN_BLOCKS = false

        TILES = {
          '3' => 5,
          '4' => 5,
          '6' => 8,
          '7' => 5,
          '8' => 18,
          '9' => 15,
          '58' => 5,
          '14' => 4,
          '15' => 4,
          '16' => 2,
          '19' => 2,
          '20' => 2,
          '23' => 5,
          '24' => 5,
          '25' => 4,
          '26' => 2,
          '27' => 2,
          '28' => 2,
          '29' => 2,
          '30' => 2,
          '31' => 2,
          '87' => 4,
          '88' => 4,
          '204' => 4,
          '207' => 1,
          '619' => 4,
          '622' => 1,
          '39' => 2,
          '40' => 2,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '44' => 2,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '63' => 7,
          '70' => 2,
          '611' => 3,
          '216' => 2,
          '911' => 4,
        }.freeze

        LOCATION_NAMES = {
          B12: 'Campbell Hall',
          B2: 'Syracuse',
          C3: 'Albany',
          C5: 'Hudson',
          C9: 'Rhinecliff',
          C11: 'Poughkeepsie',
          C17: 'White Plains',
          C19: 'New York',
          D4: 'New Lebanon',
          E13: 'Danbury',
          E15: 'Stamford',
          F2: 'Burlington',
          F4: 'Pittsfield',
          F14: 'Bridgeport',
          G11: 'Middletown',
          G13: 'New Haven',
          H4: 'Greenfield',
          H6: 'Northampton',
          H8: 'Springfield',
          H10: 'Hartford',
          H14: 'Saybrook',
          I13: 'New London',
          J6: 'Worcester',
          J14: 'Westerly',
          K1: 'New Hampshire',
          K3: 'Fitchburg',
          K5: 'Leominster',
          L4: 'Lowell and Wilmington',
          L8: 'Woonsocket',
          L10: 'Providence',
          M1: 'Portland',
          M5: 'Boston',
          M7: 'Quincy',
          O11: 'Cape Cod',
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
            tiles: %i[yellow],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5E',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6E',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '8',
            on: '8E',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
          #    status: ['can_buy_companies'],
          #    status: %w[can_buy_companies export_train],
          #    status: %w[can_buy_companies export_train],
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 100,
            rusts_on: '4',
            num: 10,
          },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6E',
            num: 7,
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: '8E',
            num: 4,
          },
          {
            name: '5E',
            distance: 5,
            price: 500,
            num: 4,
          },
          {
            name: '6E',
            distance: 6,
            price: 600,
            num: 3,
          },
          {
            name: '8E',
            distance: 8,
            price: 800,
            num: 20,
          },
        ].freeze

        COMPANIES = [
                  {
            name: 'Delaware and Raritan Canal',
            value: 20,
            revenue: 5,
            desc: 'No special ability. Blocks hex K3 while owned by a player.',
            sym: 'D&R',
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'AWS',
            name: 'Albany and West Stockbridge Railroad',
            coordinates: 'C3',
           city: 0,
            logo: '18_new_england/AWS',
            color: 'red',
            tokens: [0],
            float_percent: 100,
            shares: [100],
            type: 'minor',
            reservation_color: nil,
          },
          {
            sym: 'BL',
            name: 'Boston and Lowell Railroad',
            coordinates: 'M5',
                       city: 1,
            logo: '18_new_england/BL',
            color: 'orange',
            tokens: [0],
            float_percent: 100,
            shares: [100],
            type: 'minor',
            reservation_color: nil,
          },
          {
            sym: 'BP',
            name: 'Boston & Providence',
            coordinates: 'L10',
            logo: '18_new_england/BP',
            color: 'black',
            tokens: [0],
            float_percent: 100,
            shares: [100],
            type: 'minor',
            reservation_color: nil,
          },
          {
            sym: 'CR',
            name: 'Connecticut River',
            coordinates: 'GH',
                       city: 0,
            logo: '18_new_england/CR',
            color: 'brown',
            tokens: [0],
            float_percent: 100,
            shares: [100],
            type: 'minor',
            reservation_color: nil,
          },
          {
            sym: 'CV',
            name: 'Connecticut Valley',
            coordinates: 'F2',
            logo: '18_new_england/CV',
            color: 'yellow',
            tokens: [0],
            float_percent: 100,
            shares: [100],
            type: 'minor',
            reservation_color: nil,
          },
          {
            sym: 'ER',
            name: 'Eastern Railroad',
            coordinates: 'M5',
                       city: 0,
            logo: '18_new_england/ER',
            color: 'purple',
            tokens: [0],
            float_percent: 100,
            shares: [100],
            type: 'minor',
            reservation_color: nil,
          },
          {
            sym: 'FRR',
            name: 'Fitchburg Railroad',
            coordinates: 'K3',
            logo: '18_new_england/FRR',
            color: 'green',
            tokens: [0],
            float_percent: 100,
            shares: [100],
            type: 'minor',
            reservation_color: nil,
          },
          {
            sym: 'GR',
            name: 'Granite Railway',
            coordinates: 'M7',
            logo: '18_new_england/GR',
            color: 'olive',
            tokens: [0],
            float_percent: 100,
            shares: [100],
            type: 'minor',
            reservation_color: nil,
          },
          {
            sym: 'HNH',
            name: 'Hartford and New Haven',
            coordinates: 'G13',
                       city: 0,
            logo: '18_new_england/HNH',
            color: 'magenta',
            tokens: [0],
            float_percent: 100,
            shares: [100],
            type: 'minor',
            reservation_color: nil,
          },
          {
            sym: 'HRR',
            name: 'Hudson Railroad',
            coordinates: 'C3',
                       city: 1,
            logo: '18_new_england/HRR',
            color: 'navy',
            tokens: [0],
            float_percent: 100,
            shares: [100],
            type: 'minor',
            reservation_color: nil,
          },
          {
            sym: 'NLN',
            name: 'New London Northern Railroad',
            coordinates: 'G13',
                       city: 1,
            logo: '18_new_england/NLN',
            color: 'lightBlue',
            tokens: [0],
            float_percent: 100,
            shares: [100],
            type: 'minor',
            reservation_color: nil,
          },
          {
            sym: 'NYNH',
            name: 'New York New Haven Railroad',
            coordinates: 'G13',
                       city: 2,
            logo: '18_new_england/NYNH',
            color: 'darkOrange',
            tokens: [0],
            float_percent: 100,
            shares: [100],
            type: 'minor',
            reservation_color: nil,
          },
          {
            sym: 'NYW',
            name: 'New York Westchester Boston',
            coordinates: 'C19',
            logo: '18_new_england/NYW',
            color: 'red',
            tokens: [0],
            float_percent: 100,
            shares: [100],
            type: 'minor',
            reservation_color: nil,
          },
          {
            sym: 'PE',
            name: 'Poughkeepsie and Eastern Railway',
            coordinates: 'C11',
            logo: '18_new_england/PE',
            color: 'black',
            tokens: [0],
            float_percent: 100,
            shares: [100],
            type: 'minor',
            reservation_color: nil,
          },
          {
            sym: 'WNR',
            name: 'Worcester, Nashua and Rochester Railroad',
            coordinates: 'J6',
            logo: '18_new_england/WNR',
            color: 'black',
            tokens: [0],
            float_percent: 100,
            shares: [100],
            type: 'minor',
            reservation_color: nil,
          },
        ].freeze

        # rubocop:disable Layout/LineLength
        HEXES = {
          white: {
            %w[B16 B6 C13 D10 D12 D14 D16 D2 D6 D8 E3 G3 G7 G9 I11 I3 I9 J10 J12 J4 J8 K11 K13 K7 L2 M11 M9 N10 N8 O9 L6] => 'blank',
            %w[E11 E5 E7 E9 F10 F6 F8 G5 I5 I7] => 'upgrade=cost:40,terrain:mountain',
            %w[B10 B14 B18 B8 C15 C7 H12 H2 K9 M3] => 'upgrade=cost:20,terrain:water',
            %w[C17 C9 D4 F14 G11 H14 H6 J14 K5 L8] => 'town=revenue:0',
            %w[C5 E15 F12 F4 I13] => 'city=revenue:0',
            %w[B12 E13 H4] => 'city=revenue:0;upgrade=cost:20,terrain:water',
            %w[M7] => 'town=revenue:20,loc:1;city=revenue:20,loc:center;path=a:_1,b:_0',
            %w[N4] => 'town=revenue:10;path=a:1,b:_0;upgrade=cost:20,terrain:water',
          },
          yellow: {
            %w[L10] => 'city=revenue:30;path=a:_0,b:2;path=a:_0,b:3;upgrade=cost:20,terrain:water;label=Y',
            %w[C3] => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:5,b:_1;label=Y',
            %w[C11] => 'city=revenue:20;path=a:_0,b:0;path=a:_0,b:3',
            %w[G13] => 'city=revenue:30;city=revenue:30;city=revenue:30;path=a:_0,b:1;path=a:_1,b:3;path=a:_2,b:5;label=NH',
            %w[H10] => 'city=revenue:30;path=a:_0,b:1;path=a:_0,b:2;label=H',
            %w[H8] => 'city=revenue:20;city=revenue:20;path=a:_0,b:1;path=a:_1,b:3',
            %w[J6] => 'city=revenue:20;path=a:_0,b:4;path=a:_0,b:5',
            %w[K3] => 'city=revenue:20;path=a:_0,b:0;path=a:_0,b:1;upgrade=cost:20,terrain:water',
            %w[L4] => 'city=revenue:20,loc:center;town=revenue:10,loc:5;path=a:5,b:_0',
            %w[M5] => 'city=revenue:30;city=revenue:30;path=a:2,b:_0;path=a:4,b:_1;label=B',
          },
          gray: {
            %w[A13] => 'path=a:4,b:5',
            %w[B4] => 'path=a:4,b:5',
            %w[E17] => 'path=a:2,b:3',
            %w[G15] => 'path=a:2,b:3;path=a:3,b:4',
            %w[O11] => 'town=revenue:40;path=a:2,b:_0;path=a:_0,b:3',
          },
          red: {
            %w[B2] => 'offboard=revenue:yellow_0|green_20|brown_30|gray_30;path=a:5,b:_0',
            %w[C19] => 'city=revenue:yellow_40|green_50|brown_70|gray_100;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
            %w[F2] => 'city=revenue:yellow_30|green_40|brown_50|gray_60;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            %w[K1] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_60;path=a:0,b:_0;path=a:5,b:_0',
            %w[M1] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_60;path=a:0,b:_0;path=a:1,b:_0',
          },
        }.freeze
        # rubocop:enable Layout/LineLength

        LAYOUT = :flat

        HOME_TOKEN_TIMING = :float
        MUST_BUY_TRAIN = :always # mostly true, needs custom code
        SELL_MOVEMENT = :down_block_pres
        SELL_BUY_ORDER = :sell_buy

        # Two lays or one upgrade
        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: true, upgrade: :not_if_upgraded},
        ].freeze
      end
    end
  end
end
