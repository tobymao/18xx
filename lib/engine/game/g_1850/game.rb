# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'stock_market'

module Engine
  module Game
    module G1850
      class Game < Game::Base
        include_meta(G1850::Meta)

        register_colors(black: '#37383a',
                        orange: '#f48221',
                        brightGreen: '#76a042',
                        red: '#d81e3e',
                        turquoise: '#00a993',
                        blue: '#0189d1',
                        brown: '#7b352a')

        CURRENCY_FORMAT_STR = '$%d'

        BANK_CASH = 12_000

        CERT_LIMIT = {
          2 => { '9' => 24, '8' => 21 },
          3 => { '9' => 17, '8' => 15 },
          4 => { '9' => 14, '8' => 12 },
          5 => { '9' => 11, '8' => 9 },
          6 => { '9' => 9, '8' => 8 },
        }.freeze

        STARTING_CASH = { 2 => 1050, 3 => 700, 4 => 525, 5 => 420, 6 => 350 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = true

        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 3,
          '4' => 4,
          '5' => 2,
          '6' => 2,
          '7' => 6,
          '8' => 20,
          '9' => 20,
          '14' => 4,
          '15' => 4,
          '16' => 1,
          '17' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 4,
          '24' => 4,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 3,
          '42' => 3,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '55' => 1,
          '56' => 1,
          '57' => 5,
          '58' => 4,
          '63' => 4,
          '70' => 1,
          '129' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:50,slots:2,loc:3;city=revenue:50,slots:1,loc:0.5;'\
            'path=a:0,b:_1;path=a:1,b:_1;path=a:2,b:_0;path=a:3,b:_0;label=Chi',
          },
          '130' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:70,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
            'path=a:3,b:_0;path=a:5,b:_0;label=Chi',
          },
          '131' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:100,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
            'path=a:3,b:_0;label=Chi',
          },
          '132' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0,'\
            'path=a:2,b:_0;label=Mil',
          },
          '133' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0,'\
            'path=a:2,b:_0;label=Mil',
          },
          '134' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0,'\
            'path=a:2,b:_0;label=Mil',
          },
          '135' =>
          {
            'count' => 3,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0,'\
            'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=KMS',
          },
          '138' =>
          {
            'count' => 2,
            'color' => 'gray',
            'code' =>
            'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0,'\
            'path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=KMS',
          },
          '141' => 1,
          '142' => 1,
          '143' => 1,
          '144' => 1,
          '145' => 1,
          '146' => 1,
          '147' => 1,
        }.freeze

        LOCATION_NAMES = {
          'A2' => 'Northwest',
          'A10' => 'Mesabi Range',
          'B5' => 'Fargo',
          'B11' => 'Duluth',
          'C20' => 'Sault Ste. Marie',
          'D10' => 'Minneapolis & St. Paul',
          'E4' => 'Sioux Falls',
          'E18' => 'Green Bay',
          'F1' => 'West',
          'F13' => 'La Crosse',
          'G4' => 'Sioux City',
          'G16' => 'Madison',
          'G18' => 'Milwaukee',
          'H9' => 'Des Moines',
          'H11' => 'Cedar Rapids',
          'I4' => 'Omaha',
          'I12' => 'Rock Island',
          'I18' => 'Chicago',
          'J11' => 'Burlington & Quincy',
          'K4' => 'Topeka',
          'K6' => 'Kansas City',
          'K14' => 'Springfield',
          'K20' => 'East',
          'L13' => 'St. Louis',
          'M1' => 'Southwest',
          'M7' => 'Springfield',
          'M20' => 'South',
        }.freeze

        MARKET = [
          %w[64y 68 72 76 82 90 100p 110 120 140 160 180 200 225 250 270 300 325 350 375 400],
          %w[60y 64y 68 72 76 82 90 100p 110 120 140 160 180 200 225 250 270 300 325 350 375],
          %w[55y 60y 64y 68 72 78 82p 90 100 110 120 140 160 180 200 225 250i 285i 300i 325i 350i],
          %w[50o 55y 60y 64y 68 72 76p 82 90 100 110 120 140 160i 180i 200i 225i 250i 285i 300i 325i],
          %w[40o 50o 55y 60y 64 68 72p 76 82 90 100 110i 120i 140i 160i 180i],
          %w[30b 40o 50o 55y 60y 64 68p 72 76 82 90i 100i 110i],
          %w[20b 30b 40o 50o 55y 60 64 68 72 76i 82i],
          %w[10b 20b 30b 40o 50y 55y 60 64 68i 72i],
          %w[0c 10b 20b 30b 40o 50y 55y 60i 64i],
          %w[0c 0c 10b 20b 30b 40o 50y],
          %w[0c 0c 0c 10b 20b 30b 40o],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
            status: ['can_buy_companies_from_other_players'],
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies can_buy_companies_from_other_players],
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
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown gray blue],
            operating_rounds: 3,
          },
          {
            name: '10',
            on: '10',
            train_limit: 2,
            tiles: %i[yellow green brown gray blue],
            operating_rounds: 3,
          },
          {
            name: '12',
            on: '12',
            train_limit: 2,
            tiles: %i[yellow green brown gray blue],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [{ name: '2', distance: 2, price: 80, rusts_on: '4', num: 6 },
                  {
                    name: '3',
                    distance: 3,
                    price: 180,
                    rusts_on: '6',
                    num: 6,
                    events: [{ 'type' => 'companies_buyable' }],
                  },
                  { name: '4', distance: 4, price: 300, rusts_on: '8', num: 4 },
                  {
                    name: '5',
                    distance: 5,
                    price: 450,
                    rusts_on: '12',
                    num: 3,
                    events: [{ 'type' => 'close_companies' }],
                  },
                  {
                    name: '6',
                    distance: 6,
                    price: 630,
                    num: 3,
                    events: [{ 'type' => 'remove_tokens' }],
                  },
                  { name: '8', distance: 8, price: 800, num: 3 },
                  { name: '10', distance: 10, price: 950, num: 2 },
                  { name: '12', distance: 12, price: 1100, num: 20 }].freeze

        # COMPANIES = [
        #   {
        #     name: 'Great River Shipping Company',
        #     value: 20,
        #     revenue: 5,
        #     desc: 'The GRSC has no special features.',
        #     sym: 'GRSC',
        #     color: nil,
        #   },
        #   {
        #     name: 'Crédit Mobilier',
        #     value: 40,
        #     revenue: 10,
        #     desc: 'If the Union Pacific corporation purchases this company, it may pay up to triple the value to'\
        #           ' the owner of the Crédit Mobilier. If the Crédit Mobilier is owned by any Corporation, the president'\
        #           ' always gets the $10 income. The corporation owning the Crédit Mobilier may do one extra yellow track'\
        #           ' lay west of the Mississippi River. This company survices until phase six as a non-revenue paying'\
        #           ' company if the extra track lay has not been done.',
        #     sym: 'CM',
        #     abilities: [
        #       {
        #         type: 'tile_lay',
        #         owner_type: 'corporation',
        #         count: 1,
        #         reachable: true,
        #         special: false,
        #         when: 'track',
        #         hexes: %w[A4 B3 B5 C2 C4 C6 D3 D5 D7 E2 E4 E6 E8 F3 F5 F7 F9 F11 G2 G4 G6 G8 G10 H3 H5 H7 H9 I2 I4
        #                   I6 I8 I10 J3 J5 J7 J8 K2 K4 K6 K8 K10 L4 L6 L8 L10 L12 M4 M6 M8 M10],
        #         tiles: %w[1 2 3 4 5 6 7 8 9 55 56 57 58 69],
        #       },
        #     ],
        #     color: nil,
        #   },
        #   {
        #     name: 'Mississippi Bridge Company',
        #     value: 40,
        #     revenue: 10,
        #     desc: 'This company gives the purchasing corporation a free bridge over the Mississippi River at'\
        #           ' St. Louis (i.e., free track lay in hex L13). For the Missouri Pacific this track lay is in addition'\
        #           ' to and may be performed before its normal track lay/upgrade. This company may be sold during phase 2'\
        #           ' for half to full face value. If a corporation uses this company to lay the St. Louis hex, it may not'\
        #           ' upgraded that hex in the same operating turn.',
        #     sym: 'MBC',
        #     abilities: [
        #       {
        #         type: 'tile_discount',
        #         discount: 40,
        #         hexes: ['L13'],
        #         when: 'owning_corp_or_turn',
        #         count: 1,
        #         owner_type: 'corporation',
        #       },
        #     ],
        #     color: nil,
        #   },
        #   {
        #     name: 'Gant Brothers Construction Company',
        #     value: 50,
        #     revenue: 10,
        #     desc: 'The corporation that owns this company may purchase a yellow track lay each turn for $30. The'\
        #           ' corporation must also pay any terrain costs. This track lay is in addition to any track lay or upgrade'\
        #           ' it is allowed to do. This company survives until phase six as a non-revenue paying company.',
        #     sym: 'GBC',
        #     abilities: [
        #       {
        #         type: 'assign_hexes',
        #         hexes: %w[H17 M14 M20 N7 N17],
        #         count: 2,
        #         owner_type: 'corporation',
        #         when: 'owning_corp_or_turn',
        #       },
        #       {
        #         type: 'assign_corporation',
        #         when: 'sold',
        #         count: 1,
        #         owner_type: 'corporation',
        #       },
        #     ],
        #     color: nil,
        #   },
        #   {
        #     name: 'Mesabi Mining Company',
        #     value: 80,
        #     revenue: 15,
        #     desc: 'Comes with a Mesabi Range token.'\
        #           ' '\
        #           ' The Mesabi Mining Company gives the owning corporation a token for the Mesabi Range without further'\
        #           ' cost. When other corporations connect to the Mesabi Range, the corporation owning the Mesabi Mining'\
        #           ' Company receives $40 (half of the $80 connection fee). The owning corporation stops receiving this'\
        #           ' payment when the private company is closed.'\
        #           ' '\
        #           ' This company may be bought in during phase two from half to full face value. '\
        #           ' '\
        #           ' The company closes on the first 5T, but the owning corporation always has the right to the Mesabi'\
        #           ' Range. No corporation may connect to the Mesabi Range until the Mesabi Mining Company has been bought'\
        #           ' into a corporation or closed by the sale of the first 5T. There are four Mesabi Range tokens. Max one'\
        #           ' per corporation.',
        #     sym: 'MRC',
        #     # abilities: [{
        #     #   type: 'shares',
        #     #   shares: 'SLSF_0' }
        #     #   , { type: 'no_buy' }],
        #     color: nil,
        #   },
        #   {
        #     name: 'Western Land Grant Company',
        #     value: 90,
        #     revenue: 20,
        #     desc: 'The corporation owning the Western Land Grant is allowed extra construction of yellow track. During'\
        #           ' the track laying phase, the owning corporation is allowed to lay a second tile which must be yellow. The'\
        #           ' owning corporation may do this up to three times. Two of these track lays must be used west of the'\
        #           ' Mississippi river, one may be used anywhere on the map. If none of the track lays have been used, this'\
        #           ' company survives until phase six as a non-revenue company.',
        #     sym: 'MKT',
        #     # abilities: [{
        #     #   type: 'shares',
        #     #   shares: 'MKT_1',
        #     # }],
        #     color: nil,
        #   },
        # ].freeze

        CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'CBQ',
            name: 'Chicago, Burlington & Quincy Railroad',
            logo: '1870/ATSF',
            simple_logo: '1870/ATSF.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'I18',
            color: '#b3b3b3',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'MILW',
            name: 'The Milwaukee Road',
            logo: '1870/SSW',
            simple_logo: '1870/SSW.alt',
            tokens: [0, 40, 100],
            abilities: [{ type: 'assign_hexes', hexes: ['A2'], count: 1 }],
            coordinates: 'G18',
            color: '#d27926',
            text_color: 'black',

            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'CRI&P',
            name: 'Chicago, Rock Island & Pacific',
            logo: '1870/SP',
            simple_logo: '1870/SP.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'H11',
            color: '#980000',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'GNR',
            name: 'Great Northern Railway',
            logo: '1870/SLSF',
            simple_logo: '1870/SLSF.alt',
            tokens: [0, 40, 100],
            abilities: [{ type: 'assign_hexes', hexes: ['A2'], count: 1 }],
            coordinates: 'D9',
            color: '#67d7ce',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'Katy',
            name: 'Missouri-Kansas-Texas Railroad',
            logo: '1870/MKT',
            simple_logo: '1870/MKT.alt',
            tokens: [0, 40, 100],
            abilities: [{ type: 'assign_hexes', hexes: ['M2'], count: 1 }],
            coordinates: 'K6',
            color: '#018471',
            reservation_color: nil,
          },

          {
            float_percent: 60,
            sym: 'MP',
            name: 'Missouri Pacific',
            logo: '1870/IC',
            simple_logo: '1870/IC.alt',
            tokens: [0, 40, 100],
            coordinates: 'L13',
            color: '#0f08bc',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'GNR',
            name: 'Great Northern Railway',
            logo: '1870/GMO',
            simple_logo: '1870/GMO.alt',
            tokens: [0, 40, 100],
            abilities: [{ type: 'assign_hexes', hexes: ['A2'], count: 1 }],
            coordinates: 'D9',
            color: '#00ddee',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'SOO',
            name: 'The Soo Line',
            logo: '1870/FW',
            simple_logo: '1870/FW.alt',
            tokens: [0, 40, 100],
            abilities: [{ type: 'assign_hexes', hexes: ['F1'], count: 1 }],
            coordinates: 'F13',
            color: '#ff0000',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'UP',
            name: 'Union Pacific Railroad',
            logo: '1870/GMO',
            simple_logo: '1870/GMO.alt',
            tokens: [0, 40, 100],
            abilities: [{ type: 'assign_hexes', hexes: ['A2'], count: 1 }],
            coordinates: 'I4',
            color: '#ffff00',
            text_color: 'black',
            reservation_color: nil,
          },
        ].freeze

        HEXES = {
          white: {
            %w[A4 A6 A8 A14 B3 B9 C2 C4 C6 C10 C12 C14 C18 D3 D5 D11 D15 D17
               E2 E6 E8 E14 E16 F5 F7 F9 F11 F17 G2 G6 G8 G14 H3 H7 H15 I6 I10
               I14 J3 J7 J9 J13 J15 J17 J19 K2 K10 K16 K18 L3 L5 L7 L15 L17 L19
               M6 M10 M14 M16] => '',
            %w[B5 B11 E4 E18 G16 H9 K4 K14 M8] => 'city=revenue:0',
            %w[C16 D7 D13 F15 G10 I2 I16 M4 M18] => 'town=revenue:0',
            ['I7'] => 'town=revenue:0;town=revenue:0',
            %w[B13 C8 D19 E12 F3 G12 H5 H13 J5 K12 L9 L11] => 'upgrade=cost:40,terrain:water',
            ['A12'] => 'upgrade=cost:60,terrain:mountain',
            %w[B7 I12 K8 M12] => 'town=revenue:0;upgrade=cost:40,terrain:water',
            %w[E10 J11] => 'town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:water',
            %w[F13 G4 I4] => 'city=revenue:0;upgrade=cost:40,terrain:water',
            %w[D9 K6 L13] => 'label=P;city=revenue:0;upgrade=cost:40,terrain:water',
            ['I18'] => 'label=C,city=revenue:0,loc:1.5;city=revenue:0,loc:4.5;'\
                       'upgrade=cost:40,terrain:water',
          },
          gray: {
            ['A10'] => 'town=revenue:yellow_30|brown_40|gray_60;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;' \
                       'path=a:5,b:_0;icon=image:1828/coal;icon=image:1828/coal',
            ['I20'] => 'path=a:0,b:1',
          },
          red: {
            ['A2'] =>
              'city=revenue:yellow_30|brown_40|,slots:0;path=a:0,b:_0,lanes:2,terminal:1;'\
              'path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['B1'] =>
              'path=a:3,b:4,a_lane:2.0;path=a:3,b:5,a_lane:2.1',
            ['C20'] =>
              'city=revenue:yellow_20|brown_40|gray_50,slots:1;path=a:0,b:_0;path=a:1,b:_0',
            ['F1'] =>
              'city=revenue:yellow_30|brown_40,slots:0;path=a:3,b:_0,terminal:1;'\
              'path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['K20'] =>
              'city=revenue:yellow_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;'\
              'path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1',
            ['M2'] =>
              'city=revenue:yellow_30|brown_40,slots:0;path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1',
            ['M20'] =>
              'city=revenue:yellow_20|brown_30|gray_40;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1',
          },
          yellow: {
            ['G18'] =>
              'label=M;city=revenue:20,slots:1;path=a:1,b:_0;upgrade=cost:40,terrain:water',
            ['H11'] =>
              'city=revenue:20,slots:1;path=a:1,b:_0;path=a:4,b:_0',
          },
        }.freeze

        LAYOUT = :pointy
      end
    end
  end
end
