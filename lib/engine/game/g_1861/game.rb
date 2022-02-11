# frozen_string_literal: true

require_relative 'meta'
require_relative '../g_1867/game'

module Engine
  module Game
    module G1861
      class Game < G1867::Game
        include_meta(G1861::Meta)

        CURRENCY_FORMAT_STR = '%d₽'

        TILES = {
          '3' => 2,
          '4' => 4,
          '5' => 2,
          '6' => 2,
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '14' => 2,
          '15' => 2,
          '16' => 2,
          '17' => 2,
          '18' => 2,
          '19' => 2,
          '20' => 2,
          '21' => 2,
          '22' => 2,
          '23' => 5,
          '24' => 5,
          '25' => 4,
          '26' => 2,
          '27' => 2,
          '28' => 2,
          '29' => 2,
          '30' => 2,
          '31' => 2,
          '39' => 2,
          '40' => 2,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '44' => 2,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '57' => 2,
          '58' => 4,
          '63' => 3,
          '87' => 2,
          '88' => 2,
          '201' => 3,
          '202' => 3,
          '204' => 2,
          '207' => 5,
          '208' => 2,
          '611' => 3,
          '619' => 2,
          '621' => 2,
          '622' => 2,
          '623' => 3,
          '624' => 1,
          '625' => 1,
          '626' => 1,
          '635' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,loc:0.5;city=revenue:40,loc:2.5;city=revenue:40,loc:4.5;'\
                      'path=a:0,b:_0;path=a:_0,b:1;path=a:4,b:_2;path=a:_2,b:5;path=a:2,b:_1;'\
                      'path=a:_1,b:3;label=K;upgrade=cost:40,terrain:water',
          },
          '636' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=K',
          },
          '637' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,loc:0.5;city=revenue:50,loc:2.5;city=revenue:50,loc:4.5;'\
                      'path=a:0,b:_0;path=a:_0,b:1;path=a:4,b:_2;path=a:_2,b:5;'\
                      'path=a:2,b:_1;path=a:_1,b:3;label=M',
          },
          '638' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=M',
          },
          '639' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:100,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=M',
          },
          '640' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Kh',
          },
          '641' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=S',
          },
          '642' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=S',
          },
          '801' => 2,
          '911' => 3,
        }.freeze

        LOCATION_NAMES = {
          'A9' => 'Poland',
          'B4' => 'Riga',
          'B8' => 'Vilna',
          'B18' => 'Romania',
          'C5' => 'Dünaberg',
          'C9' => 'Minsk',
          'D14' => 'Kiev',
          'D20' => 'Odessa',
          'E1' => 'St. Petersburg',
          'E9' => 'Smolensk',
          'E11' => 'Gomel',
          'E13' => 'Chernigov',
          'F18' => 'Ekaterinoslav',
          'G5' => 'Tver',
          'G13' => 'Kursk',
          'G15' => 'Kharkov',
          'G19' => 'Alexandrovsk',
          'H8' => 'Moscow',
          'H10' => 'Tula',
          'H18' => 'Yuzovka',
          'I5' => 'Yaroslav',
          'I13' => 'Voronezh',
          'I17' => 'Lugansk',
          'I19' => 'Rostov',
          'J20' => 'Caucasus',
          'K7' => 'Nizhnii Novgorod',
          'K11' => 'Penza',
          'K17' => 'Tsaritsyn',
          'L12' => 'Saratov',
          'M7' => 'Kazan',
          'M9' => 'Simbirsk',
          'M19' => 'Astrakhan',
          'N10' => 'Samara',
          'P0' => 'Perm',
          'P8' => 'Ufa',
          'Q3' => 'Ekaterinburg (₽80 if includes M)',
          'Q11' => 'Central Asia',
        }.freeze

        PHASES = [
          {
            name: '2',
            train_limit: { minor: 2 },
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '3',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            status: ['can_buy_companies'],
            on: '3',
            operating_rounds: 2,
          },
          {
            name: '4',
            train_limit: { minor: 1, major: 3, national: 99 },
            tiles: %i[yellow green],
            status: %w[can_buy_companies national_operates],
            on: '4',
            operating_rounds: 2,
          },
          {
            name: '5',
            train_limit: { minor: 1, major: 3, national: 99 },
            tiles: %i[yellow green brown],
            status: %w[can_buy_companies national_operates],
            on: '5',
            operating_rounds: 2,
          },
          {
            name: '6',
            train_limit: { minor: 1, major: 2, national: 99 },
            tiles: %i[yellow green brown gray],
            on: '6',
            operating_rounds: 2,
            status: ['national_operates'],
          },
          {
            name: '7',
            train_limit: { minor: 1, major: 2, national: 99 },
            tiles: %i[yellow green brown gray],
            on: '7',
            operating_rounds: 2,
            status: ['national_operates'],
          },
          {
            name: '8',
            train_limit: { major: 2, national: 99 },
            tiles: %i[yellow green brown gray],
            on: '8',
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 100,
            rusts_on: '4',
            num: 10,
          },
          {
            name: '3',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 225,
            rusts_on: '6',
            num: 7,
            events: [{ 'type' => 'green_minors_available' }],
          },
          {
            name: '4',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 350,
            rusts_on: '8',
            num: 4,
            events: [{ 'type' => 'majors_can_ipo' },
                     { 'type' => 'trainless_nationalization' }],
          },
          {
            name: '5',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 550,
            num: 4,
            events: [{ 'type' => 'minors_cannot_start' }],
          },
          {
            name: '6',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 650,
            num: 2,
            events: [{ 'type' => 'nationalize_companies' },
                     { 'type' => 'trainless_nationalization' }],
          },
          {
            name: '7',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 7, 'visit' => 7 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 800,
            num: 2,
          },
          {
            name: '8',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 8, 'visit' => 8 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 1000,
            num: 20,
            events: [{ 'type' => 'signal_end_game' },
                     { 'type' => 'minors_nationalized' },
                     { 'type' => 'trainless_nationalization' }],
          },
          {
            name: '2+2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            multiplier: 2,
            price: 600,
            num: 20,
            available_on: '8',
          },
          {
            name: '5+5E',
            distance: [{ 'nodes' => ['offboard'], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => %w[city town], 'pay' => 0, 'visit' => 99 }],
            multiplier: 2,
            price: 1500,
            num: 20,
            available_on: '8',
          },
        ].freeze

        COMPANIES = [
          {
            name: 'rules until start of phase 3',
            sym: '3',
            value: 3,
            revenue: 0,
            desc: 'Hidden corporation',
            abilities: [{ type: 'blocks_hexes', hexes: %w[E3 H6 I5 I9 J10] }],
            color: nil,
          },
          {
            name: 'Tsarskoye Selo Railway',
            sym: 'TSR',
            value: 30,
            revenue: 10,
            discount: 10,
            desc: 'No special abilities.',
            color: nil,
          },
          {
            name: 'Black Sea Shipping Company',
            sym: 'BSS',
            value: 45,
            revenue: 15,
            discount: 15,
            desc: 'When owned by a corporation, they gain 10₽ extra revenue for '\
                  'each of their routes that include Odessa',
            abilities: [
              {
                type: 'hex_bonus',
                owner_type: 'corporation',
                hexes: ['D20'],
                amount: 10,
              },
            ],
            color: nil,
          },
          {
            name: 'Moscow - Yaroslavl Railway',
            sym: 'MYR',
            value: 60,
            revenue: 20,
            discount: 20,
            desc: 'When owned by a corporation, they gain 10₽ extra revenue for '\
                  'each of their routes that include Moscow',
            abilities: [
              {
                type: 'hex_bonus',
                owner_type: 'corporation',
                hexes: ['H8'],
                amount: 10,
              },
            ],
            color: nil,
          },
          {
            name: 'Moscow - Ryazan Railway',
            sym: 'MRR',
            value: 75,
            revenue: 25,
            discount: 25,
            desc: 'When owned by a corporation, they gain 10₽ extra revenue for '\
                  'each of their routes that include Moscow',
            abilities: [
              {
                type: 'hex_bonus',
                owner_type: 'corporation',
                hexes: ['H8'],
                amount: 10,
              },
            ],
            color: nil,
          },
          {
            name: 'Warsaw - Vienna Railway',
            sym: 'WVR',
            value: 90,
            revenue: 30,
            discount: 30,
            desc: 'When owned by a corporation, they gain 10₽ extra revenue for '\
                  'each of their routes that include Poland',
            abilities: [
              {
                type: 'hex_bonus',
                owner_type: 'corporation',
                hexes: %w[A9 A11 A13 A15],
                amount: 10,
              },
            ],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'NW',
            name: 'North Western Railway',
            logo: '1861/NW',
            simple_logo: '1861/NW.alt',
            float_percent: 20,
            always_market_price: true,
            tokens: [0, 20, 40],
            type: 'major',
            color: '#000080',
            reservation_color: nil,
          },
          {
            sym: 'SW',
            name: 'Southwestern Railway',
            logo: '1861/SW',
            simple_logo: '1861/SW.alt',
            float_percent: 20,
            always_market_price: true,
            tokens: [0, 20, 40],
            type: 'major',
            color: '#d75500',
            reservation_color: nil,
          },
          {
            sym: 'SE',
            name: 'Southeastern Railway',
            logo: '1861/SE',
            simple_logo: '1861/SE.alt',
            float_percent: 20,
            always_market_price: true,
            tokens: [0, 20, 40],
            type: 'major',
            color: '#772282',
            reservation_color: nil,
          },
          {
            sym: 'MVR',
            name: 'Moscow, Vindava & Rybinsk Railway',
            logo: '1861/MVR',
            simple_logo: '1861/MVR.alt',
            float_percent: 20,
            always_market_price: true,
            tokens: [0, 20, 40],
            type: 'major',
            color: '#808000',
            reservation_color: nil,
          },
          {
            sym: 'MK',
            name: 'Moscow & Kazan Railway',
            logo: '1861/MK',
            simple_logo: '1861/MK.alt',
            float_percent: 20,
            always_market_price: true,
            tokens: [0, 20, 40],
            type: 'major',
            color: '#7b352a',
            reservation_color: nil,
          },
          {
            sym: 'GRR',
            name: 'Grand Russian Railway',
            logo: '1861/GRR',
            simple_logo: '1861/GRR.alt',
            float_percent: 20,
            always_market_price: true,
            tokens: [0, 20, 40],
            type: 'major',
            color: '#ef4223',
            reservation_color: nil,
          },
          {
            sym: 'MKN',
            name: 'Moscow, Kursk & Nizhnii Novgorod',
            logo: '1861/MKN',
            simple_logo: '1861/MKN.alt',
            float_percent: 20,
            always_market_price: true,
            tokens: [0, 20, 40],
            type: 'major',
            color: '#0189d1',
            reservation_color: nil,
          },
          {
            sym: 'MKV',
            name: 'Moscow, Kiev & Voronezh Railway',
            logo: '1861/MKV',
            simple_logo: '1861/MKV.alt',
            float_percent: 20,
            always_market_price: true,
            tokens: [0, 20, 40],
            type: 'major',
            color: '#3c7b5c',
            reservation_color: nil,
          },
          {
            sym: 'RO',
            name: 'Riga-Orel Railway',
            logo: '1861/RO',
            simple_logo: '1861/RO.alt',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            type: 'minor',
            coordinates: 'B4',
            shares: [100],
            max_ownership_percent: 100,
            color: '#009595',
            reservation_color: nil,
          },
          {
            sym: 'KB',
            name: 'Kiev-Brest Railway',
            logo: '1861/KB',
            simple_logo: '1861/KB.alt',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            coordinates: 'D14',
            city: 1,
            color: '#4cb5d2',
            reservation_color: nil,
          },
          {
            sym: 'OK',
            name: 'Odessa-Kiev Railway',
            logo: '1861/OK',
            simple_logo: '1861/OK.alt',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            coordinates: 'D20',
            color: '#0097df',
            reservation_color: nil,
          },
          {
            sym: 'KK',
            name: 'Kiev-Kursk Railway',
            logo: '1861/KK',
            simple_logo: '1861/KK.alt',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            coordinates: 'D14',
            city: 2,
            color: '#0097df',
            reservation_color: nil,
          },
          {
            sym: 'SPW',
            name: 'St. Petersburg Warsaw',
            logo: '1861/SPW',
            simple_logo: '1861/SPW.alt',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            coordinates: 'E1',
            city: 0,
            color: '#0189d1',
            reservation_color: nil,
          },
          {
            sym: 'MB',
            name: 'Moscow-Brest Railway',
            logo: '1861/MB',
            simple_logo: '1861/MB.alt',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            coordinates: 'E9',
            color: '#000080',
            reservation_color: '#009a54ff',
          },
          {
            sym: 'KR',
            name: 'Kharkiv-Rostov Railway',
            logo: '1861/KR',
            simple_logo: '1861/KR.alt',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            coordinates: 'G15',
            color: '#772282',
            reservation_color: nil,
          },
          {
            sym: 'N',
            name: 'Nikolaev Railway',
            logo: '1861/N',
            simple_logo: '1861/N.alt',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            coordinates: 'H8',
            city: 1,
            color: '#d30869',
            reservation_color: nil,
          },
          {
            sym: 'Y',
            name: 'Yuzovka Railway',
            logo: '1861/Y',
            simple_logo: '1861/Y.alt',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            coordinates: 'H18',
            color: '#f3716d',
            reservation_color: '#009a54ff',
          },
          {
            sym: 'M-K',
            name: 'Moscow-Kursk Railway',
            logo: '1861/M-K',
            simple_logo: '1861/M-K.alt',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            coordinates: 'H8',
            city: 0,
            color: '#d75500',
            reservation_color: nil,
          },
          {
            sym: 'MNN',
            name: 'Moscow-Nizhnii Novgorod',
            logo: '1861/MNN',
            simple_logo: '1861/MNN.alt',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            coordinates: 'H8',
            city: 2,
            color: '#ef4223',
            reservation_color: nil,
          },
          {
            sym: 'MV',
            name: 'Moscow-Voronezh Railway',
            logo: '1861/MV',
            simple_logo: '1861/MV.alt',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            coordinates: 'I13',
            color: '#b7274c',
            reservation_color: nil,
          },
          {
            sym: 'V',
            name: 'Vladikavkaz Railway',
            logo: '1861/V',
            simple_logo: '1861/V.alt',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            coordinates: 'I19',
            color: '#7c7b8c',
            reservation_color: '#009a54ff',
          },
          {
            sym: 'TR',
            name: 'Tsaritsyn-Riga Railway',
            logo: '1861/TR',
            simple_logo: '1861/TR.alt',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            coordinates: 'K17',
            color: '#7c7b8c',
            reservation_color: '#009a54ff',
          },
          {
            sym: 'SV',
            name: 'Samara-Vyazma Railway',
            logo: '1861/SV',
            simple_logo: '1861/SV.alt',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            coordinates: 'N10',
            color: '#7c7b8c',
            reservation_color: '#009a54ff',
          },
          {
            sym: 'E',
            name: 'Ekaterinin Railway',
            logo: '1861/E',
            simple_logo: '1861/E.alt',
            float_percent: 100,
            always_market_price: true,
            tokens: [0],
            shares: [100],
            max_ownership_percent: 100,
            type: 'minor',
            coordinates: 'Q3',
            color: '#000080',
            reservation_color: '#009a54ff',
          },
          {
            sym: 'RSR',
            name: 'Russian State Railway',
            logo: '1861/RSR',
            simple_logo: '1861/RSR.alt',
            tokens: [0, 0, 0, 0, 0, 0, 0, 0],
            shares: [100],
            hide_shares: true,
            type: 'national',
            coordinates: 'E1',
            city: 1,
            color: '#fffdd0',
            text_color: 'black',
            reservation_color: nil,
          },
        ].freeze

        HEXES = {
          white: {
            %w[B6 B10 B12 B14 B16 C3 C13 C15 D6 D8 D16 D18 E3 E5 E7 E17 F6 F8
               F10 F12 F14 F20 G3 G9 G11 G17 H2 H4 H6 H12 H14 H16 H20 I3 I7 I9
               I11 J2 J4 J8 J10 J12 J14 K3 K5 K9 K13 K15 K19 L2 L4 L8 L10 L14
               L18 L20 M3 M5 N2 N4 N8 N12 N20 O1 O3 O7 O9 O11 P6 P10 P12] => '',
            %w[B8 C9 E11 E13 G19 G13 H10 I17 K11] => 'town=revenue:0',
            ['I5'] => 'town=revenue:0;upgrade=cost:20,terrain:water',
            ['M9'] => 'town=revenue:0;upgrade=cost:80,terrain:water',
            %w[E9 H18 I13 I19 K17 L12 P8] => 'city=revenue:0',
            ['P2'] => 'city=revenue:0;upgrade=cost:20,terrain:water',
            %w[F18 M7] => 'city=revenue:0;upgrade=cost:40,terrain:water',
            %w[B4 D20 M19 N10] => 'city=revenue:0;label=Y',
            ['G15'] => 'city=revenue:0;label=Y;label=Kh',
            %w[C11 D12 M11] => 'upgrade=cost:80,terrain:water',
            %w[E15 E19 F16 I15 J16 J18] => 'upgrade=cost:40,terrain:water',
            %w[C17 C19 D10 J6 L6 N6 O5 P4] => 'upgrade=cost:20,terrain:water',
          },
          gray: {
            ['A5'] => 'path=a:4,b:5',
            ['C5'] => 'town=revenue:10;path=a:2,b:_0;path=a:5,b:_0;path=a:0,b:4',
            ['C21'] => 'path=a:4,b:3',
            ['M21'] => 'path=a:3,b:2',
            ['P0'] => 'path=a:0,b:1',
            ['Q7'] => 'path=a:1,b:2',
            ['Q5'] => 'path=a:3,b:2;path=a:3,b:1',
            ['Q3'] => 'city=revenue:40;path=a:2,b:_0;path=a:1,b:_0;path=a:0,b:_0',
          },
          yellow: {
            %w[C7 D4] => 'path=a:3,b:1',
            %w[F4 G7] => 'path=a:3,b:5',
            ['D2'] => 'path=a:0,b:4',
            ['F2'] => 'path=a:0,b:2',
            ['G5'] => 'town=revenue:10;path=a:2,b:_0;path=a:0,b:_0',
            ['H8'] =>
            'city=revenue:40;city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2;label=M',
            ['D14'] =>
            'city=revenue:30;city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2;label=K',
            ['K7'] =>
            'city=revenue:30;path=a:1,b:_0;path=a:5,b:_0;label=Y;upgrade=cost:20,terrain:water',
          },
          green: {
            ['E1'] => 'city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:_1,b:5;label=S',
          },
          red: {
            ['A9'] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70,groups:Poland;'\
                      'path=a:5,b:_0;path=a:4,b:_0;border=edge:0',
            %w[A11 A13] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70,hide:1,groups:Poland;'\
                           'path=a:5,b:_0;path=a:4,b:_0;border=edge:3;border=edge:0',
            ['A15'] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70,hide:1,groups:Poland;'\
                       'path=a:5,b:_0;path=a:4,b:_0;border=edge:3',
            ['B18'] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_30,groups:Romania;'\
                       'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;border=edge:0',
            ['B20'] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_30,hide:1,groups:Romania;'\
                       'path=a:4,b:_0;border=edge:3',
            ['J20'] => 'offboard=revenue:yellow_10|green_20|brown_40|gray_60,groups:Caucasus;'\
                       'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;border=edge:1;border=edge:5',
            ['I21'] => 'offboard=revenue:yellow_10|green_20|brown_40|gray_60,hide:1,groups:Caucasus;'\
                       'path=a:3,b:_0;border=edge:4',
            ['K21'] => 'offboard=revenue:yellow_10|green_20|brown_40|gray_60,hide:1,groups:Caucasus;'\
                       'path=a:3,b:_0;path=a:4,b:_0;border=edge:2',
            ['Q11'] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_40,groups:CentralAsia;'\
                       'path=a:1,b:_0;path=a:2,b:_0;border=edge:0',
            ['Q13'] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_40,hide:1,groups:CentralAsia;'\
                       'path=a:2,b:_0;border=edge:3',
          },
          blue: {},
        }.freeze

        LAYOUT = :flat

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'national_operates' => ['National railway operates',
                                  'After the minors and majors operates the national runs trains, '\
                                  'withholds and buys as many trains as possible'],
        ).freeze
        GREEN_CORPORATIONS = %w[MB Y V TR SV E].freeze

        # This is Kh in 1861
        HEX_WITH_O_LABEL = %w[G15].freeze
        HEX_UPGRADES_FOR_O = %w[201 202 207 208 621 622 623 801 640].freeze
        BONUS_CAPITALS = %w[H8].freeze
        BONUS_REVENUE = 'Q3'
        NATIONAL_RESERVATIONS = %w[E1 H8].freeze

        def game_market
          @optional_rules&.include?(:column_market) ? self.class::COLUMN_MARKET : self.class::GRID_MARKET
        end

        def all_corporations
          corporations + [@national]
        end

        def unstarted_corporation_summary
          unipoed = (@corporations + @future_corporations).reject(&:ipoed)
          minor = unipoed.select { |c| c.type == :minor }
          major = unipoed.select { |c| c.type == :major }
          ["#{major.size} major", [@national] + minor]
        end

        def init_loans
          @loan_value = 50
          # 16 minors * 2, 8 majors * 5
          # The national can take an infinite (100)
          Array.new(172) { |id| Loan.new(id, @loan_value) }
        end

        def home_token_locations(corporation)
          # Can only place home token in cities that have no other tokens.
          open_locations = hexes.select do |hex|
            hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) && city.tokens.none? }
          end

          unconnected_hexes(open_locations)
        end

        def place_rsr_home_token
          # RSR on first run places their home token...
          # unless RSR already has a token due to SPW nationalization,
          # in which case the reservation on the other city is removed
          tile = hex_by_id('E1').tile
          return unless @national_reservations.include?(tile.hex.id)
          return if tile.cities.any? { |c| c.tokened_by?(@national) }

          return unless (new_token = @national.next_token)

          @log << "#{@national.name} places a token on #{tile.hex.location_name}"
          @national_reservations.delete(tile.hex.id)
          # St Petersburg slot is the 2nd one
          tile.cities.last.place_token(@national, new_token, check_tokenable: false)
        end

        def nationalization_loan_movement(corporation)
          corporation.loans.each do
            stock_market.move_left(corporation)
          end
        end

        def nationalization_transfer_assets(corporation)
          receiving = []
          companies = transfer(:companies, corporation, @national).map(&:name)
          receiving << "companies (#{companies.join(', ')})" unless companies.empty?

          trains = transfer(:trains, corporation, @national).map(&:name)
          receiving << "trains (#{trains})" unless trains.empty?
          receiving << 'and' unless receiving.empty?
          receiving << format_currency(corporation.cash).to_s
          corporation.spend(corporation.cash, @national) if corporation.cash.positive?
          @log << "#{@national.id} received #{receiving} from #{corporation.id}"
        end

        def maximum_loans(entity)
          entity.type == :national ? 100 : super
        end

        def operating_order
          minors, majors = @corporations.select(&:floated?).sort.partition { |c| c.type == :minor }
          minors + majors + [@national]
        end

        def add_neutral_tokens
          # 1861 doesn't have neutral tokens
          @green_tokens = []
        end

        def stock_round
          G1867::Round::Stock.new(self, [
            G1867::Step::MajorTrainless,
            Engine::Step::DiscardTrain,
            Engine::Step::HomeToken,
            G1861::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          @national.owner = priority_deal_player
          @log << "#{@national.name} run by #{@national.owner.name}, as they have priority deal"
          calculate_interest
          G1861::Round::Operating.new(self, [
            G1867::Step::MajorTrainless,
            G1861::Step::BuyCompany,
            G1867::Step::RedeemShares,
            G1861::Step::Track,
            G1861::Step::Token,
            G1861::Step::Route,
            G1861::Step::Dividend,
            # The blocking buy company needs to be before loan operations
            [G1861::Step::BuyCompanyPreloan, { blocks: true }],
            G1867::Step::LoanOperations,
            Engine::Step::DiscardTrain,
            G1861::Step::BuyTrain,
            [G1861::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def or_round_finished; end

        def event_signal_end_game!
          if @round.round_num == 1
            # If first round
            # The current OR now has 3 rounds and finishes
            @operating_rounds = @final_operating_rounds = 3
            @final_turn = @turn
            @log << "First 8 train bought/exported, ending game at the end of #{@turn}.#{@final_operating_rounds},"\
                    ' skipping the next OR and SR'
          else
            # Else finish this OR, do the stock round then 3 more ORs
            @final_operating_rounds = 3
            @log << "First 8 train bought/exported, ending game at the end of #{@turn + 1}.#{@final_operating_rounds}"
          end

          # Hit the game end check now to set the correct turn
          game_end_check
        end
      end
    end
  end
end
