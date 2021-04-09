# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G1835
      class Game < Game::Base
        include_meta(G1835::Meta)

        register_colors(black: '#37383a',
                        seRed: '#f72d2d',
                        bePurple: '#2d0047',
                        peBlack: '#000',
                        beBlue: '#c3deeb',
                        heGreen: '#78c292',
                        oegray: '#6e6966',
                        weYellow: '#ebff45',
                        beBrown: '#54230e',
                        gray: '#6e6966',
                        red: '#d81e3e',
                        turquoise: '#00a993',
                        blue: '#0189d1',
                        brown: '#7b352a')

        CURRENCY_FORMAT_STR = '%dM'
        # game end current or, when the bank is empty
        GAME_END_CHECK = { bank: :current_or }.freeze
        # bankrupt is allowed, player leaves game
        BANKRUPTCY_ALLOWED = true

        BANK_CASH = 12_000

        CERT_LIMIT = { 3 => 19, 4 => 15, 5 => 12, 6 => 11, 7 => 9 }.freeze

        STARTING_CASH = { 3 => 600, 4 => 475, 5 => 390, 6 => 340, 7 => 310 }.freeze
        # money per initial share sold
        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false

        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 2,
          '4' => 3,
          '5' => 3,
          '6' => 3,
          '7' => 8,
          '8' => 16,
          '9' => 12,
          '55' => 1,
          '56' => 1,
          '57' => 2,
          '58' => 4,
          '69' => 2,
          '201' => 2,
          '202' => 2,
          '12' => 2,
          '13' => 2,
          '14' => 2,
          '15' => 2,
          '16' => 2,
          '18' => 1,
          '19' => 2,
          '20' => 2,
          '23' => 3,
          '24' => 3,
          '25' => 3,
          '26' => 2,
          '27' => 2,
          '28' => 2,
          '29' => 2,
          '87' => 2,
          '88' => 2,
          '203' => 2,
          '204' => 2,
          '205' => 1,
          '206' => 1,
          '207' => 2,
          '208' => 2,
          '209' => 1,
          '210' => 1,
          '211' => 1,
          '212' => 1,
          '213' => 1,
          '214' => 1,
          '215' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 2,
          '42' => 2,
          '43' => 1,
          '44' => 2,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '63' => 3,
          '70' => 1,
          '216' => 4,
          '217' => 2,
          '218' => 2,
          '219' => 2,
          '220' => 1,
          '221' => 1,
        }.freeze

        LOCATION_NAMES = {
          'A11' => 'Kiel',
          'C11' => 'Hamburg',
          'C13' => 'Schwerin',
          'D6' => 'Oldenburg',
          'D8' => 'Bremen',
          'F10' => 'Hannover',
          'F12' => 'Braunschweig',
          'F14' => 'Magdeburg',
          'G3' => 'Duisburg Essen',
          'G5' => 'Dortmund',
          'H2' => 'Düsseldorf',
          'H16' => 'Leipzig',
          'H20' => 'Dresden',
          'J6' => 'Mainz Wiesbaden',
          'J8' => 'Frankfurt',
          'L6' => 'Ludwigshafen Mannheim',
          'L14' => 'Fürth Nürnberg',
          'M9' => 'Stuttgart',
          'N12' => 'Augsburg',
          'O5' => 'Freiburg',
          'O15' => 'München',
        }.freeze

        MARKET = [['',
                   '',
                   '',
                   '',
                   '132',
                   '148',
                   '166',
                   '186',
                   '208',
                   '232',
                   '258',
                   '286',
                   '316',
                   '348',
                   '382',
                   '418'],
                  ['',
                   '',
                   '98',
                   '108',
                   '120',
                   '134',
                   '150',
                   '168',
                   '188',
                   '210',
                   '234',
                   '260',
                   '288',
                   '318',
                   '350',
                   '384'],
                  %w[82
                     86
                     92p
                     100
                     110
                     122
                     136
                     152
                     170
                     190
                     212
                     236
                     262
                     290
                     320],
                  %w[78
                     84p
                     88p
                     94
                     102
                     112
                     124
                     138
                     154p
                     172
                     192
                     214],
                  %w[72 80p 86 90 96 104 114 126 140],
                  %w[64 74 82 88 92 98 106],
                  %w[54 66 76 84 90]].freeze

        PHASES = [
          {
            name: '1.1',
            on: '2',
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '1.2',
            on: '2+2',
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '2.1',
            on: '3',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '2.2',
            on: '3+3',
            train_limit: { major: 4, minor: 2 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '2.3',
            on: '4',
            train_limit: { prussian: 4, major: 3, minor: 1 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '2.4',
            on: '4+4',
            train_limit: { prussian: 4, major: 3, minor: 1 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '3.1',
            on: '5',
            train_limit: { prussian: 3, major: 2 },
            tiles: %i[yellow green],
            operating_rounds: 3,
            events: { close_companies: true },
          },
          {
            name: '3.2',
            on: '5+5',
            train_limit: { prussian: 3, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '3.3',
            on: '6',
            train_limit: { prussian: 3, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '3.4',
            on: '6+6',
            train_limit: { prussian: 3, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [{ name: '2', distance: 2, price: 80, rusts_on: '4', num: 9 },
                  { name: '2+2', distance: 2, price: 120, rusts_on: '4+4', num: 4 },
                  { name: '3', distance: 3, price: 180, rusts_on: '6', num: 4 },
                  { name: '3+3', distance: 3, price: 270, rusts_on: '6+6', num: 3 },
                  { name: '4', distance: 4, price: 360, num: 3 },
                  { name: '4+4', distance: 4, price: 440, num: 1 },
                  { name: '5', distance: 5, price: 500, num: 2 },
                  { name: '5+5', distance: 5, price: 600, num: 1 },
                  { name: '6', distance: 6, price: 600, num: 2 },
                  { name: '6+6', distance: 6, price: 720, num: 4 }].freeze

        COMPANIES = [
          {
            name: 'Leipzig-Dresdner Bahn',
            sym: 'LD',
            value: 190,
            revenue: 20,
            desc: 'Leipzig-Dresdner Bahn - Sachsen Direktor Papier',
            abilities: [{ type: 'shares', shares: %w[SX_0] },
                        { type: 'no_buy' },
                        { type: 'close', when: 'bought_train', corporation: 'SX' }],
            color: nil,
          },
          {
            name: 'Ostbayrische Bahn',
            sym: 'OBB',
            value: 120,
            revenue: 10,
            desc: 'Ostbayrische Bahn - 2 Tiles on M15, M17 extra (one per OR) and without cost',
            abilities: [
              {
                type: 'tile_lay',
                description: "Place a free track tile at m15, M17 at any time during the corporation's operations.",
                owner_type: 'player',
                hexes: %w[M15 M17],
                tiles: %w[3 4 7 8 9 58],
                free: true,
                count: 1,
              },
              { type: 'shares', shares: 'BY_1' },
            ],
            color: nil,
          },
          {
            name: 'Nürnberg-Fürth',
            sym: 'NF',
            value: 100,
            revenue: 5,
            desc: 'Nürnberg-Fürth Bahn, Director of AG may lay token on L14 north or south',
            abilities: [{ type: 'shares', shares: 'BY_2' }],
            color: nil,
          },
          {
            name: 'Hannoversche Bahn',
            sym: 'HB',
            value: 160,
            revenue: 30,
            desc: '10 Percent Share of Preussische Bahn on Exchange',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[PR_1],
                owner_type: 'player',
                when: ['Phase 2.3', 'Phase 2.4', 'Phase 3.1'],
                # reserved papers perhaps a option
                from: 'ipo',
              },
            ],
            color: nil,
          },
          {
            name: 'Pfalzbahnen',
            sym: 'PB',
            value: 150,
            revenue: 15,
            desc: 'Can lay a tile on L6 and Token on L6 if Baden AG is active already',
            abilities: [
              {
                type: 'teleport',
                owner_type: 'player',
                free_tile_lay: true,
                hexes: ['L6'],
                tiles: %w[210 211 212 213 214 215],
              },
              { type: 'shares', shares: 'BY_3' },
            ],
            color: nil,
          },
          {
            name: 'Braunschweigische Bahn',
            sym: 'BB',
            value: 130,
            revenue: 25,
            desc: 'Can be exchanged for a 10% share of Preussische Bahn',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[PR_2],
                owner_type: 'player',
                when: ['Phase 2.3', 'Phase 2.4', 'Phase 3.1'],
                from: 'ipo',
              },
            ],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'BY',
            name: 'Bayrische Eisenbahn',
            logo: '1835/BY',
            simple_logo: '1835/BY.alt',
            tokens: [0, 0, 0, 0, 0],
            float_percent: 50,
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            coordinates: 'O15',
            color: :Blue,
            reservation_color: nil,
          },
          {
            sym: 'SX',
            name: 'Sächsische Eisenbahn',
            logo: '1835/SX',
            simple_logo: '1835/SX.alt',
            tokens: [0, 0, 0],
            float_percent: 50,
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            coordinates: 'H16',
            color: '#d81e3e',
            reservation_color: nil,
          },
          {
            sym: 'BA',
            name: 'Badische Eisenbahn',
            logo: '1835/BA',
            simple_logo: '1835/BA.alt',
            tokens: [0, 0],
            float_percent: 50,
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            # last_cert = true,
            coordinates: 'L6',
            color: '#7b352a',
            reservation_color: nil,
          },
          {
            sym: 'HE',
            name: 'Hessische Eisenbahn',
            logo: '1835/HE',
            simple_logo: '1835/HE.alt',
            tokens: [0, 0],
            float_percent: 50,
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            last_cert: %w[HE_7],
            # last_cert = true,
            coordinates: 'J8',
            color: :green,
            reservation_color: nil,
          },
          {
            sym: 'WT',
            name: 'Württembergische Eisenbahn',
            logo: '1835/WT',
            simple_logo: '1835/WT.alt',
            tokens: [0, 0],
            float_percent: 50,
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            last_cert: ['WT_7'],
            # last_cert = true,
            coordinates: 'M9',
            color: :yellow,
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: 'MS',
            name: 'Eisenbahn Mecklenburg Schwerin',
            logo: '1835/MS',
            simple_logo: '1835/MS.alt',
            tokens: [0, 0],
            percent: 10,
            float_percent: 60,
            shares: [20, 10, 20, 20, 10, 10, 10],
            # the shares order creates a 10 share company, but the first 3 sold papers are 20%
            coordinates: 'C13',
            color: :violet,
            reservation_color: nil,
          },
          {
            sym: 'OL',
            name: 'Oldenburgische Eisenbahn',
            logo: '1835/OL',
            simple_logo: '1835/OL.alt',
            tokens: [0, 0],
            float_percent: 60,
            shares: [20, 10, 20, 20, 10, 10, 10],
            # the shares order creates a 10 share company, but the first 3 sold papers are 20%
            coordinates: 'D6',
            color: '#6e6966',
            reservation_color: nil,
          },

          {
            sym: 'PR',
            name: 'Preussische Eisenbahn',
            logo: '1835/PR',
            simple_logo: '1835/PR.alt',
            tokens: [0, 0, 0, 0, 0],
            shares: [10, 10, 10, 10, 10, 10, 10, 10, 5, 5, 5, 5],
            # shares for minors and Privates should be reserved
            coordinates: 'E19',
            color: '#37383a',
            reservation_color: nil,
          },
        ].freeze

        MINORS = [
          {
            sym: 'P1',
            name: 'Bergisch Märkische Bahn',
            logo: '1835/PR',
            simple_logo: '1835/PR.alt',
            tokens: [0],
            abilities: [
              {
                type: 'exchange',
                corporations: %w[PR_9],
                owner_type: 'player',
                when: ['Phase 2.3', 'Phase 2.4', 'Phase 3.1'],
                # reserved papers perhaps a option
                from: 'ipo',
              },
            ],
            coordinates: 'H2',
            color: '#37383a',
          },
          {
            sym: 'P2',
            name: 'Berlin Potsdamer Bahn',
            logo: '1835/PR',
            simple_logo: '1835/PR.alt',
            tokens: [0],
            abilities: [
              {
                type: 'exchange',
                corporations: %w[PR_0x],
                owner_type: 'player',
                when: ['Phase 2.3', 'Phase 2.4', 'Phase 3.1'],
                # reserved papers perhaps a option
                from: 'ipo',
              },
            ],
            coordinates: 'E19',
            color: '#37383a',
          },
          {
            sym: 'P3',
            name: 'Magdeburger-Bahn',
            logo: '1835/PR',
            simple_logo: '1835/PR.alt',
            tokens: [0],
            abilities: [
              {
                type: 'exchange',
                corporations: %w[PR_10],
                owner_type: 'player',
                when: ['Phase 2.3', 'Phase 2.4', 'Phase 3.1'],
                # reserved papers perhaps a option
                from: 'ipo',
              },
            ],
            coordinates: 'F14',
            color: '#37383a',
          },
          {
            sym: 'P4',
            name: 'Köln-Mindener Bahn',
            logo: '1835/PR',
            simple_logo: '1835/PR.alt',
            tokens: [0],
            abilities: [
              {
                type: 'exchange',
                corporations: %w[PR_3],
                owner_type: 'player',
                when: ['Phase 2.3', 'Phase 2.4', 'Phase 3.1'],
                # reserved papers perhaps a option
                from: 'ipo',
              },
            ],
            coordinates: 'G5',
            color: '#37383a',
          },
          {
            sym: 'P5',
            name: 'Berlin Stettiner Bahn',
            logo: '1835/PR',
            simple_logo: '1835/PR.alt',
            tokens: [0],
            abilities: [
              {
                type: 'exchange',
                corporations: %w[PR_11],
                owner_type: 'player',
                when: ['Phase 2.3', 'Phase 2.4', 'Phase 3.1'],
                # reserved papers perhaps a option
                from: 'ipo',
              },
            ],
            coordinates: 'E19',
            color: '#37383a',
          },
          {
            sym: 'P6',
            name: 'Altona Kiel Bahn',
            logo: '1835/PR',
            simple_logo: '1835/PR.alt',
            tokens: [0],
            abilities: [
              {
                type: 'exchange',
                corporations: %w[PR_12],
                owner_type: 'player',
                when: ['Phase 2.3', 'Phase 2.4', 'Phase 3.1'],
                # reserved papers perhaps a option
                from: 'ipo',
              },
            ],
            coordinates: 'C11',
            color: '#37383a',
          },
        ].freeze

        HEXES = {
          white: {
            %w[B18
               C15
               C17
               C19
               D10
               D12
               D16
               D18
               D20
               E5
               E7
               E9
               E11
               E13
               E17
               F8
               F16
               F18
               F20
               G7
               G9
               G17
               G19
               H14
               H18
               I5
               I11
               J2
               J10
               J12
               K5
               K13
               L4
               L10
               L12
               L16
               M11
               N14
               N16
               N18
               O9
               O11
               O13
               O17] => '',
            ['A11'] => 'city=revenue:0,loc:5.5',
            ['D8'] => 'city=revenue:0,loc:center;upgrade=cost:50',
            ['F10'] => 'city=revenue:0,loc:1.5',
            ['F14'] => 'city=revenue:0,loc:center',
            ['G5'] => 'city=revenue:0,loc:0',
            ['H2'] => 'city=revenue:0,loc:3.5;label=Y',
            ['H16'] => 'city=revenue:0,loc:2.5',
            ['H20'] => 'city=revenue:0,loc:0.5;upgrade=cost:50;label=Y',
            ['I3'] => 'city=revenue:0;label=Y;upgrade=cost:50',
            ['M9'] => 'city=revenue:0,loc:0.5',
            ['N12'] => 'city=revenue:0,loc:5',
            ['O5'] => 'city=revenue:0',
            ['O15'] => 'city=revenue:0,loc:1;label=Y',
            ['B12'] => 'town=revenue:0,loc:5.5',
            ['B14'] => 'town=revenue:0',
            ['B16'] => 'town=revenue:0,loc:3',
            ['F4'] => 'town=revenue:0,loc:4',
            ['F6'] => 'town=revenue:0,loc:2',
            ['G11'] => 'town=revenue:0,loc:0.5',
            ['G15'] => 'town=revenue:0,loc:5',
            ['H4'] => 'town=revenue:0,loc:1;town=revenue:0,loc:2.5',
            ['H10'] => 'town=revenue:0,loc:2.5',
            ['I13'] => 'upgrade=cost:70,terrain:mountain;town=revenue:0,loc:2.5',
            ['I15'] => 'town=revenue:0,loc:3.5',
            ['I17'] => 'town=revenue:0,loc:0.5;town=revenue:0,loc:3.5',
            ['K3'] => 'town=revenue:0,loc:1.5',
            ['K11'] => 'town=revenue:0,loc:1',
            ['L2'] => 'town=revenue:0,loc:4.5',
            ['L8'] => 'town=revenue:0,loc:1;town=revenue:0,loc:5',
            ['M7'] => 'town=revenue:0,loc:0;town=revenue:0,loc:1.5',
            ['N10'] => 'town=revenue:0,loc:5;town=revenue:0,loc:center',
            ['M15'] => 'upgrade=cost:50,terrain:water;town=revenue:0,loc:3',
            %w[D14 E15 K7 K9 M13 M17] => 'upgrade=cost:50,terrain:water',
            %w[G13 H6 H8 H12 I7 I9 J14 K15 N8 O7] =>
                   'upgrade=cost:70,terrain:mountain',
            ['C9'] => 'border=edge:3,type:water',
            ['B10'] => 'border=edge:0,type:water',
          },
          red: {
            ['C21'] => 'offboard=revenue:yellow_20|green_20|brown_40;path=a:1,b:_0',
            ['H22'] =>
            'offboard=revenue:yellow_20|green_30|brown_40,groups:OS;path=a:1,b:_0;border=edge:0',
            ['I21'] =>
            'offboard=revenue:yellow_20|green_30|brown_40,hide:1,groups:OS;border=edge:3',
            ['M5'] =>
            'offboard=revenue:yellow_0|green_50|brown_0,groups:Alsace;path=a:3,b:_0;border=edge:0',
            ['N4'] =>
            'offboard=revenue:yellow_0|green_50|brown_0,hide:1,groups:Alsace;path=a:4,b:_0;border=edge:3',
          },
          yellow: {
            ['E19'] =>
                     'city=revenue:30,loc:1;city=revenue:30,loc:3;path=a:1,b:_0;path=a:2,b:_1',
            ['G3'] =>
            'city=revenue:0,loc:0;city=revenue:0,loc:4.5;label=XX;upgrade=cost:50',
            ['J6'] => 'city=revenue:0;city=revenue:0;label=XX;upgrade=cost:50',
            ['L6'] => 'city=revenue:0,loc:5.5;city=revenue:0,loc:4;label=XX',
          },
          green: {
            ['C11'] =>
            'city=revenue:40;path=a:0,b:_0;city=revenue:40;path=a:2,b:_1;'\
            'city=revenue=40;path=a:4,b:_2;path=a:3,b:_2;label=HH',
            ['J8'] =>
            'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;upgrade=cost:50;label=Y',
            ['L14'] =>
            'city=revenue:30,loc:2.5;path=a:3,b:_0;path=a:2,b:_0;'\
            'city=revenue:30,loc:5.5;path=a:5,b:_1;path=a:0,b:_1;label=XX',
          },
          brown: {
            %w[A9 G1] => 'path=a:4,b:5',
            ['A17'] => 'town=revenue:10,loc:5;path=a:5,b:_0',
            ['B8'] => 'path=a:5,b:0',
            ['C5'] =>
            'town=revenue:10;path=a:4,b:_0;town=revenue:10;path=a:5,b:_1;path=a:0,b:_1',
            ['C7'] => 'town=revenue:10;path=a:3,b:_0;path=a:5,b:_0;path=a:0,b:1',
            ['C13'] =>
            'city=revenue:10,loc:3;path=a:3,b:_0;path=a:1,b:_0;path=a:1,b:5;path=a:5,b:_0',
            ['D4'] => 'path=a:3,b:5',
            ['D6'] =>
            'city=revenue:10;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['E21'] => 'town=revenue:10;path=a:1,b:_0;path=a:0,b:_0;path=a:2,b:_0',
            ['F12'] => 'city=revenue:20;path=a:1,b:_0;path=a:0,b:_0;path=a:4,b:_0',
            ['G21'] => 'path=a:2,b:0',
            ['I1'] => 'town=revenue:10;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['I19'] => 'path=a:1,b:2;path=a:2,b:3;path=a:1,b:3',
            ['J4'] => 'town=revenue:10;path=a:2,b:_0;path=a:5,b:_0;path=a:3,b:4',
            ['J16'] => 'path=a:0,b:1;path=a:0,b:3;path=a:1,b:3',
            ['M19'] => 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0',
            ['N6'] => 'path=a:0,b:1;path=a:1,b:3;path=a:0,b:3',
            %w[P6 P14] => 'path=a:2,b:3',
            ['P10'] => 'town=revenue:10;path=a:2,b:_0;path=a:3,b:_0',
          },
        }.freeze

        LAYOUT = :pointy

        SELL_MOVEMENT = :down_block

        HOME_TOKEN_TIMING = :float

        def setup
          # 1 of each right is reserved w/ the private when it gets bought in. This leaves 2 extra to sell.
          @available_bridge_tokens = 2
          @available_tunnel_tokens = 2
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Step::Bankrupt,
            Step::Exchange,
            Step::SpecialTrack,
            Step::SpecialToken,
            Step::Track,
            Step::Token,
            Step::Route,
            Step::Dividend,
            Step::DiscardTrain,
            Step::BuyTrain,
          ], round_num: round_num)
        end
      end
    end
  end
end
