# frozen_string_literal: true

require_relative '../g_1822/game'
require_relative 'meta'

module Engine
  module Game
    module G1822MX
      class Game < G1822::Game
        include_meta(G1822MX::Meta)
        include Entities

        BIDDING_BOX_START_MINOR = 'M24'
        BIDDING_BOX_START_MINOR_ADV = 'M14'

        CERT_LIMIT = { 2 => 27, 3 => 18, 4 => 14, 5 => 11, 6 => 9, 7 => 8 }.freeze

        DESTINATIONS = {
          'FCM' => 'N27',
          'MC' => 'F21',
          'CHP' => 'H11',
          'FNM' => 'G22',
          'MIR' => 'J15',
          'FCP' => 'L17',
          'IRM' => 'N27',
        }.freeze

        EXCHANGE_TOKENS = {
          'FCM' => 3,
          'MC' => 3,
          'CHP' => 3,
          'FNM' => 3,
          'MIR' => 3,
          'FCP' => 3,
          'IRM' => 3,
        }.freeze

        STARTING_CASH = { 2 => 750, 3 => 500, 4 => 375, 5 => 300, 6 => 250, 7 => 215 }.freeze

        STARTING_COMPANIES = %w[P1 P2 P5 P6 P7 P8 P9 P10 P11 P12 P13 P14 P15 P16 P18
                                C1 C2 C3 C4 C5 C6 C7 M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12 M13 M14 M15
                                M16 M17 M18 M19 M20 M21 M22 M23 M24].freeze

        STARTING_COMPANIES_ADVANCED = %w[P1 P2 P3 P4 P5 P6 P7 P8 P9 P10 P11 P12
                                         C1 C2 C3 C4 C5 C6 C7 M7 M8 M9 M10 M11 M12 M13 M14 M15
                                         M16 M17 M18 M19 M20 M21 M24].freeze

        STARTING_COMPANIES_TWOPLAYER = %w[P1 P2 P3 P4 P5 P6 P7 P8 P9 P10 P11 P12
                                          C1 C2 C3 C4 C5 C6 C7 M7 M8 M9 M10 M11 M12 M13 M14 M15
                                          M16 M17 M18 M19 M20 M21 M24].freeze

        STARTING_CORPORATIONS = %w[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24
                                   FCM MC CHP FNM MIR FCP IRM].freeze

        LOCATION_NAMES = {
          'A2' => 'San Diego',
          'B1' => 'Tijuana',
          'B3' => 'Mexicali',
          'C2' => 'C2',
          'C8' => 'C8',
          'C14' => 'C14',
          'D3' => 'D3',
          'D9' => 'D9',
          'D13' => 'D13',
          'D15' => 'D15',
          'E8' => 'E8',
          'F5' => 'F5',
          'F9' => 'F9',
          'F13' => 'F13',
          'F15' => 'F15',
          'F21' => 'F21',
          'F23' => 'F23',
          'G6' => 'G6',
          'G10' => 'G10',
          'G16' => 'G16',
          'G22' => 'G22',
          'G24' => 'G24',
          'H7' => 'H7',
          'H11' => 'H11',
          'I12' => 'I12',
          'I18' => 'I18',
          'I22' => 'I22',
          'J9' => 'J9',
          'J13' => 'J13',
          'J15' => 'J15',
          'J23' => 'J23',
          'K18' => 'K18',
          'K20' => 'K20',
          'K24' => 'K24',
          'L15' => 'L15',
          'L17' => 'L17',
          'L19' => 'L19',
          'L37' => 'L37',
          'L39' => 'L39',
          'M14' => 'M14',
          'M22' => 'M22',
          'M24' => 'M24',
          'M26' => 'M26',
          'M36' => 'M36',
          'N17' => 'N17',
          'N23' => 'N23',
          'N25' => 'N25',
          'N27' => 'N27',
          'N33' => 'N33',
          'N39' => 'N39',
          'O20' => 'O20',
          'O22' => 'O22',
          'O32' => 'O32',
          'P23' => 'P23',
          'P27' => 'P27',
          'P31' => 'P31',
          'Q34' => 'Q34',
        }.freeze

        LAYOUT = :pointy

        HEXES = {
          white: {
            %w[B5 C4 C6 D7 D11 E4 E10 E14 E16 F19 G4 G20 H21 H23 H25 I8 I24 K14 L25 M16 M38 N15 N35 N37
               O18 O28 P29 P33 Q32] =>
              '',

            %w[J25 L23 M18 N19 O26 O30 O34 P25] =>
              'upgrade=cost:20,terrain:river',
            ['N21'] =>
              'upgrade=cost:20,terrain:river;stub=edge:4',
            %w[F11 F17 G12 G18 H17 H19 I14 I20] =>
              'upgrade=cost:40,terrain:hill',
            %w[E12 H15 I16 J19 J21 L21] =>
              'upgrade=cost:80,terrain:mountain',
            ['O24'] =>
              'upgrade=cost:80,terrain:mountain;stub=edge:2',
            %w[H13 J17 K16 M20] =>
              'upgrade=cost:40,terrain:hill;upgrade=cost:20,terrain:river',
            %w[G14 K22] =>
              'upgrade=cost:80,terrain:mountain;upgrade=cost:20,terrain:river',
            ['O36'] =>
              'border=edge:0,type:impassable',
            ['P35'] =>
              'border=edge:3,type:impassable',

            %w[C2 D3 D13 F5 F9 G10 H7 I12 M14 M36 N17 N39 O20 P31] =>
              'town=revenue:0',
            %w[J23 L15 N33] =>
              'town=revenue:0;upgrade=cost:20,terrain:river',
            ['O22'] =>
              'town=revenue:0;upgrade=cost:20,terrain:river;stub=edge:3',
            ['M24'] =>
              'town=revenue:0;upgrade=cost:40,terrain:hill;stub=edge:0',
            ['G16'] =>
              'town=revenue:0;upgrade=cost:40,terrain:hill;upgrade=cost:20,terrain:river',
            ['K18'] =>
              'town=revenue:0;upgrade=cost:80,terrain:mountain',

            %w[B3 D9 D15 E8 F13 G6 G22 J13 J15 K20 N27 O32 P27] =>
              'city=revenue:0',
            %w[B1 J9 L37 L39 P23] =>
              'city=revenue:0;label=T',
            %w[F15 H11 K24] =>
              'city=revenue:0;upgrade=cost:20,terrain:river',
            ['I18'] =>
              'city=revenue:0;upgrade=cost:40,terrain:hill',

            ['M26'] =>
              'town=revenue:0;town=revenue:0',
            ['M22'] =>
              'town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:hill;upgrade=cost:20,terrain:river;stub=edge:5',

            ['N23'] =>
              'city=revenue:20;city=revenue:20;city=revenue:20;city=revenue:20;city=revenue:20;city=revenue:20;'\
              'path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;upgrade=cost:20;'\
              'label=MC',
          },
          yellow: {
            ['F21'] =>
              'city=revenue:30,slots:1;path=a:1,b:_0;path=a:5,b:_0;label=Y',
            ['I22'] =>
              'city=revenue:30,slots:1;path=a:2,b:_0;path=a:5,b:_0;label=Y',
            ['L17'] =>
              'city=revenue:30,slots:1;path=a:2,b:_0;path=a:5,b:_0;upgrade=cost:40,terrain:hill;'\
              'upgrade=cost:20,terrain:river;label=Y',
            ['L19'] =>
              'city=revenue:30,slots:1;city=revenue:30,slots:1;'\
              'path=a:0,b:_0;path=a:5,b:_0;path=a:3,b:_1;path=a:4,b:_1;'\
              'upgrade=cost:80,terrain:mountain;label=Y',
          },
          green: {
            ['N25'] =>
              'city=revenue:30,slots:1;city=revenue:30,slots:1;city=revenue:30,slots:1;'\
              'path=a:0,b:_0;path=a:5,b:_0;path=a:1,b:_1;path=a:4,b:_1;path=a:3,b:_2'\
              'label=Y',
          },
          gray: {
            ['A2'] =>
              'city=revenue:yellow_30|green_40|brown_60|gray_80,slots:2;path=a:0,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['C8'] =>
              'city=revenue:yellow_30|green_40|brown_50|gray_60,slots:2;path=a:0,b:_0;path=a:5,b:_0',
            ['C14'] =>
              'city=revenue:yellow_30|green_40|brown_50|gray_60,slots:2;path=a:0,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['F23'] =>
              'city=revenue:yellow_30|green_40|brown_50|gray_60,slots:1;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1',
            ['G24'] =>
              'city=revenue:yellow_30|green_40|brown_60|gray_80,slots:2;path=a:0,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['Q34'] =>
              'city=revenue:yellow_20|green_30|brown_40|gray_50,slots:1;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1',
          },
          blue: {
            %w[F7 H5] =>
              'junction;path=a:3,b:_0,terminal:1',
            ['G8'] =>
              'junction;path=a:1,b:_0,terminal:1',
            %w[H9 J7 J11] =>
              'junction;path=a:4,b:_0,terminal:1',
            %w[I10 M28] =>
              'junction;path=a:0,b:_0,terminal:1',
            %w[M40 Q28] =>
              'junction;path=a:2,b:_0,terminal:1',
          },
        }.freeze

        MARKET = [
          ['', '', '', '', '', '', '', '', '', '', '', '', '',
           '330', '360', '400', '450', '500e', '550e', '600e'],
          ['', '', '', '', '', '', '', '', '',
           '200', '220', '245', '270', '300', '330', '360', '400', '450', '500e', '550e'],
          %w[70 80 90 100 110 120 135 150 165 180 200 220 245 270 300 330 360 400 450 500e],
          %w[60 70 80 90 100px 110 120 135 150 165 180 200 220 245 270 300 330 360 400 450],
          %w[50 60 70 80 90px 100 110 120 135 150 165 180 200 220 245 270 300 330],
          %w[45y 50 60 70 80px 90 100 110 120 135 150 165 180 200 220 245],
          %w[40y 45y 50 60 70px 80 90 100 110 120 135 150 165 180],
          %w[35y 40y 45y 50 60px 70 80 90 100 110 120 135],
          %w[30y 35y 40y 45y 50p 60 70 80 90 100],
          %w[25y 30y 35y 40y 45y 50 60 70 80],
          %w[20y 25y 30y 35y 40y 45y 50y 60y],
          %w[15y 20y 25y 30y 35y 40y 45y],
          %w[10y 15y 20y 25y 30y 35y],
          %w[5y 10y 15y 20y 25y],
        ].freeze

        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 5,
          '4' => 5,
          '5' => 5,
          '6' => 6,
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '55' => 1,
          '56' => 1,
          '57' => 5,
          '58' => 5,
          '69' => 1,
          '14' => 5,
          '15' => 5,
          '80' => 5,
          '81' => 5,
          '82' => 6,
          '83' => 6,
          '141' => 3,
          '142' => 3,
          '143' => 3,
          '144' => 3,
          '207' => 1,
          '208' => 1,
          '619' => 5,
          '63' => 6,
          '544' => 6,
          '545' => 6,
          '546' => 8,
          '611' => 3,
          '60' => 2,
          'X20' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' =>
                'city=revenue:40;city=revenue:40;city=revenue:40;city=revenue:40;city=revenue:40;city=revenue:40;'\
                'path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;'\
                'upgrade=cost:20;label=L',
            },
          '405' =>
            {
              'count' => 2,
              'color' => 'green',
              'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=T',
            },
          'X1' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:30,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=C',
            },
          'X2' =>
            {
              'count' => 2,
              'color' => 'green',
              'code' =>
                'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                'path=a:4,b:_0;label=BM',
            },
          'X3' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:30,slots:2;path=a:1,b:_0;path=a:4,b:_0;label=S',
            },
          'X4' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;upgrade=cost:100;label=EC',
            },
          'X21' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:60;city=revenue:60;city=revenue:60;city=revenue:60;city=revenue:60;city=revenue:60;'\
                'path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;'\
                'upgrade=cost:20;label=L',
            },
          '768' =>
            {
              'count' => 3,
              'color' => 'brown',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            },
          '767' =>
            {
              'count' => 3,
              'color' => 'brown',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            },
          '769' =>
            {
              'count' => 4,
              'color' => 'brown',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
          'X5' =>
            {
              'count' => 2,
              'color' => 'brown',
              'code' =>
                'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                'path=a:4,b:_0;label=Y',
            },
          'X6' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:40,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=C',
            },
          'X7' =>
            {
              'count' => 2,
              'color' => 'brown',
              'code' =>
                'city=revenue:60,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                'path=a:5,b:_0;label=BM',
            },
          'X8' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:40,slots:2;path=a:1,b:_0;path=a:4,b:_0;label=S',
            },
          'X9' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:0,slots:2;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0,lanes:2;upgrade=cost:100;label=EC',
            },
          'X10' =>
            {
              'count' => 2,
              'color' => 'brown',
              'code' =>
                'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=T',
            },
          'X22' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:80;city=revenue:80;city=revenue:80;city=revenue:80;city=revenue:80;city=revenue:80;'\
                'path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;'\
                'upgrade=cost:20;label=L',
            },
          '169' =>
            {
              'count' => 2,
              'color' => 'gray',
              'code' =>
                'junction;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
          'X11' =>
            {
              'count' => 2,
              'color' => 'gray',
              'code' =>
                'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Y',
            },
          'X12' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:60,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=C',
            },
          'X13' =>
            {
              'count' => 2,
              'color' => 'gray',
              'code' =>
                'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                'path=a:5,b:_0;label=BM',
            },
          'X14' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:60,slots:3;path=a:1,b:_0;path=a:4,b:_0;label=S',
            },
          'X15' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:0,slots:3;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0,lanes:2;label=EC',
            },
          'X16' =>
            {
              'count' => 2,
              'color' => 'gray',
              'code' =>
                'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=T',
            },
          'X17' =>
            {
              'count' => 2,
              'color' => 'gray',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            },
          'X18' =>
            {
              'count' => 2,
              'color' => 'gray',
              'code' =>
                'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
          'X19' =>
            {
              'count' => 4,
              'color' => 'gray',
              'code' =>
                'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                'path=a:5,b:_0',
            },
          'X23' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:100;city=revenue:100;city=revenue:100;city=revenue:100;city=revenue:100;'\
                'city=revenue:100;path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;'\
                'path=a:5,b:_5;label=L',
            },
        }.freeze

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
            rusts_on: '3',
            variants: [
              {
                name: '2',
                distance: 2,
                price: 120,
                rusts_on: '4',
                available_on: '1',
              },
            ],
          },
          {
            name: '3',
            distance: 3,
            num: 7,
            price: 200,
            rusts_on: '6',
          },
          {
            name: '4',
            distance: 4,
            num: 4,
            price: 300,
            rusts_on: '7',
          },
          {
            name: '5',
            distance: 5,
            num: 2,
            price: 500,
            events: [
              {
                'type' => 'close_concessions',
              },
            ],
          },
          {
            name: '6',
            distance: 6,
            num: 3,
            price: 600,
            events: [
              {
                'type' => 'full_capitalisation',
              },
            ],
          },
          {
            name: '7',
            distance: 7,
            num: 20,
            price: 750,
            variants: [
              {
                name: 'E',
                distance: 99,
                multiplier: 2,
                price: 1000,
              },
            ],
            events: [
              {
                'type' => 'phase_revenue',
              },
            ],
          },
          {
            name: '2P',
            distance: 2,
            num: 2,
            price: 0,
          },
          {
            name: 'LP',
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
            num: 1,
            price: 0,
          },
          {
            name: '5P',
            distance: 5,
            num: 1,
            price: 500,
          },
          {
            name: 'P+',
            distance: [
              {
                'nodes' => ['city'],
                'pay' => 99,
                'visit' => 99,
              },
              {
                'nodes' => ['town'],
                'pay' => 99,
                'visit' => 99,
              },
            ],
            num: 2,
            price: 0,
          },
        ].freeze

        UPGRADE_COST_L_TO_2_PHASE_2 = 70

        def bidbox_start_minor
          return self.class::BIDDING_BOX_START_MINOR_ADV if optional_advanced?

          self.class::BIDDING_BOX_START_MINOR
        end

        def discountable_trains_for(corporation)
          discount_info = []

          upgrade_cost = if @phase.name.to_i < 2
                           self.class::UPGRADE_COST_L_TO_2
                         else
                           self.class::UPGRADE_COST_L_TO_2_PHASE_2
                         end
          corporation.trains.select { |t| t.name == 'L' }.each do |train|
            discount_info << [train, train, '2', upgrade_cost]
          end
          discount_info
        end

        def starting_companies
          return self.class::STARTING_COMPANIES_ADVANCED if optional_advanced?
          return self.class::STARTING_COMPANIES_TWOPLAYER if @players.size == 2

          self.class::STARTING_COMPANIES
        end

        def optional_advanced?
          @optional_rules&.include?(:advanced)
        end
      end
    end
  end
end
