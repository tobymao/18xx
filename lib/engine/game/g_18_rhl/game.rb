# frozen_string_literal: true

require_relative '../base'
require_relative 'meta'
require_relative '../stubs_are_restricted'

module Engine
  module Game
    module G18Rhl
      class Game < Game::Base
        include_meta(G18Rhl::Meta)

        CURRENCY_FORMAT_STR = '%dM'

        BANK_CASH = 9000

        CERT_LIMIT = { 3 => 20, 4 => 15, 5 => 12, 6 => 10 }.freeze

        STARTING_CASH = { 3 => 600, 4 => 450, 5 => 360, 6 => 300 }.freeze
        LOWER_STARTING_CASH = { 3 => 500, 4 => 375, 5 => 300, 6 => 250 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        GAME_END_CHECK = { bankrupt: :immediate, bank: :full_or }.freeze

        # Move down one step for a whole block, not per share
        SELL_MOVEMENT = :down_block

        # Cannot sell until operated
        SELL_AFTER = :operate

        # Sell zero or more, then Buy zero or one
        SELL_BUY_ORDER = :sell_buy

        # New track must be usable, or upgrade city value
        TRACK_RESTRICTION = :semi_restrictive

        TILES = {
          '1' => 2,
          '2' => 1,
          '3' => 2,
          '4' => 3,
          '5' => 1,
          '6' => 1,
          '7' => 2,
          '8' => 9,
          '9' => 9,
          '15' => 3,
          '16' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 2,
          '24' => 2,
          '25' => 2,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '55' => 2,
          '56' => 2,
          '57' => 1,
          '58' => 3,
          '69' => 2,
          '70' => 1,
          '87' => 2,
          '141' => 2,
          '142' => 2,
          '143' => 1,
          '144' => 1,
          '201' => 1,
          '202' => 1,
          '204' => 1,
          '216' => 3,
          '916' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_1;path=a:1,b:_0;path=a:3,b:_1;path=a:4,b:_0;'\
                      'label=OO',
          },
          '917' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_1;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_1;'\
                      'label=OO',
          },
          '918' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_1;path=a:4,b:_1;'\
                      'label=OO',
          },
          '919' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_1;path=a:5,b:_1;'\
                      'label=OO',
          },
          '920' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_1;path=a:1,b:_0;path=a:3,b:_1;path=a:5,b:_0;'\
                      'label=OO',
          },
          '921' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:yellow_30|green_40,slots:3;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;label=D;upgrade=cost:50,terrain:river',
          },
          '922' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:yellow_30|green_40,slots:3;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;label=D;upgrade=cost:50,terrain:river',
          },
          '923' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:yellow_30|green_40,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;label=K;upgrade=cost:50,terrain:river',
          },
          '924' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:yellow_30|green_40,slots:3;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;label=K;upgrade=cost:50,terrain:river',
          },
          '925' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:yellow_30|green_40,slots:3;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;label=DU;upgrade=cost:50,terrain:river',
          },
          '926' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:yellow_30|green_40,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;'\
                      'path=a:5,b:_0;label=DU;upgrade=cost:50,terrain:river',
          },
          '927' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;label=D;upgrade=cost:50,terrain:river',
          },
          '928' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;label=K;upgrade=cost:50,terrain:river',
          },
          '929' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;label=DU;upgrade=cost:50,terrain:river',
          },
          '930' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;upgrade=cost:30,terrain:mountain;label=AC',
          },
          '931' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:3;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;label=AC',
          },
          '932' =>
          {
            'count' => 2,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;label=D/DU/K',
          },
          '932V' =>
          {
            'count' => 2,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;label=D/K',
          },
          '933' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;',
          },
          '934' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;label=Y',
          },
          '935' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:20,loc:center;town=revenue:10,loc:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:4,b:_0;path=a:5,b:_0;label=Osterath',
          },
          '937' =>
          {
            'count' => 3,
            'color' => 'yellow',
            'code' => 'city=revenue:20;city=revenue:20;path=a:0,b:_0;path=a:4,b:_1;label=OO',
          },
          '938' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_1;label=OO',
          },
          '941' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:2,b:_1;path=a:5,b:_1;label=OO',
          },
          '942' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:3,b:_0;path=a:5,b:_1;label=OO',
          },
          '947' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=Moers',
          },
          '948' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
                      'label=OO',
          },
          '949' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3,loc:center;town=revenue:20,loc:4;path=a:0,b:_0;path=a:1,b:_0;'\
                      'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=DU',
          },
          '950' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:30,slots:2,loc:center;town=revenue:10,loc:4;path=a:0,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Moers',
          },
          '1910' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:10,loc:4;path=a:0,b:2;path=a:0,b:_0;path=a:2,b:_0;label=Ratingen',
          },
          '1911' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:20,loc:4;path=a:0,b:2;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=Ratingen',
          },
          'Essen' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3,loc:center;town=revenue:20,loc:4;path=a:0,b:_0;path=a:1,b:_0;'\
                      'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Essen',
          },
        }.freeze

        LOCATION_NAMES = {
          'A14' => 'Hamburg Münster',
          'B9' => 'Wesel',
          'B15' => 'Berlin Minden',
          'C12' => 'Herne Gelsenkirchen',
          'C14' => 'Östliches Rihrgebiet',
          'D7' => 'Moers',
          'D9' => 'Duisburg',
          'D11' => 'Oberhausen Mülheim',
          'D13' => 'Essen',
          'D15' => 'Östliches Rihrgebiet',
          'E6' => 'Krefeld',
          'E12' => 'Ratingen',
          'F9' => 'Neuss Düsseldorf',
          'F13' => 'Elberfeld Barmen',
          'G6' => 'M-Gladbach Rheydt',
          'G12' => 'Remshcheid Solingen',
          'I10' => 'Köln Deutz',
          'K2' => 'Aachen',
          'K6' => 'Düren',
          'K10' => 'Bonn',
          'J15' => 'Siegerland',
          'L1' => 'Liege',
          'L11' => 'Basel',
          'L13' => 'Frankfurt',
        }.freeze

        MARKET = [%w[75
                     80
                     90
                     100p
                     110
                     120
                     135
                     150
                     165
                     180
                     200
                     220
                     240
                     265
                     320
                     350],
                  %w[70
                     75
                     80p
                     90p
                     100
                     110
                     120
                     135
                     150
                     165
                     180
                     200
                     220
                     240],
                  %w[65
                     70p
                     75p
                     80
                     90
                     100
                     110
                     120
                     135
                     150
                     165],
                  %w[60p 65p 70 75 80 90 100],
                  %w[55 60 65 70],
                  %w[50 55 60]].freeze

        PHASES = [
          {
            name: '2',
            on: '2',
            train_limit: 4,
            tiles: [:yellow],
            status: [],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            status: [],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            status: [],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            status: [],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            status: [],
            operating_rounds: 3,
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            status: [],
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
          },
          {
            name: '3',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            num: 5,
            price: 200,
            rusts_on: '6',
          },
          {
            name: '4',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            num: 3,
            price: 300,
            rusts_on: '8',
          },
          {
            name: '5',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            num: 3,
            price: 500,
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '6',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            num: 6,
            price: 600,
          },
          {
            name: '8',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 8, 'visit' => 99 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            num: 4,
            price: 800,
            available_on: '6',
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 50,
            name: 'Aachen-Düsseldorf-Ruhrorter E.',
            sym: 'ADR',
            tokens: [0, 60, 80],
            logo: '18Rhl/ADR',
            simple_logo: '18Rhl/ADR.alt',
            color: :green,
            coordinates: 'K2',
          },
          {
            name: 'Bergisch-Märkische Eisenbahngesell.',
            sym: 'BME',
            float_percent: 50,
            tokens: [0, 60, 80, 100],
            logo: '18Rhl/BME',
            simple_logo: '18Rhl/BME.alt',
            color: :brown,
            coordinates: 'F13',
            city: 1,
          },
          {
            name: 'Cöln-Mindener Eisenbahngesellschaft',
            sym: 'CME',
            float_percent: 50,
            tokens: [0, 60, 80, 100],
            color: :red,
            logo: '18Rhl/CME',
            simple_logo: '18Rhl/CME.alt',
            coordinates: 'I10',
            city: 2,
          },
          {
            name: 'Düsseldorf Elberfelder Eisenbahn',
            sym: 'DEE',
            float_percent: 50,
            tokens: [0, 60],
            logo: '18Rhl/DEE',
            simple_logo: '18Rhl/DEE.alt',
            color: :yellow,
            text_color: 'black',
            coordinates: 'F9',
            city: 1,
          },
          {
            name: 'Krefeld-Kempener Eisenbahn',
            sym: 'KKK',
            float_percent: 60,
            tokens: [0, 60],
            shares: [20, 20, 20, 10, 10, 10, 10],
            logo: '18Rhl/KKK',
            simple_logo: '18Rhl/KKK.alt',
            color: :orange,
            coordinates: 'D7',
            abilities: [
              {
                type: 'base',
                description: 'Two double (20%) certificates',
                desc_detail: 'The first two shares sold from IPO are double (20%) certificates',
              },
            ],
          },
          {
            name: 'Gladbach-Venloer Eisenbahn',
            sym: 'GVE',
            float_percent: 50,
            tokens: [0, 60],
            logo: '18Rhl/GVE',
            simple_logo: '18Rhl/GVE.alt',
            color: :gray,
            coordinates: 'G6',
            city: 1,
          },
          {
            name: 'Cöln-Crefelder Eisenbahn',
            sym: 'CCE',
            float_percent: 50,
            tokens: [0, 0, 80],
            color: :blue,
            logo: '18Rhl/CCE',
            simple_logo: '18Rhl/CCE.alt',
            coordinates: %w[E6 I10],
            city: 1,
            abilities: [
              {
                type: 'base',
                description: 'Two home stations (Köln & Krefeld)',
              },
            ],
          },
          {
            name: 'Rheinische Eisenbahngesellschaft',
            sym: 'RhE',
            float_percent: 50,
            tokens: [0, 60, 80, 100],
            color: :purple,
            logo: '18Rhl/RhE',
            simple_logo: '18Rhl/RhE.alt',
            coordinates: 'I10',
            city: 0,
            abilities: [
              {
                type: 'base',
                description: 'Special par/float rules',
                desc_detail: "When the president's share is acquired (via private No. 6) 3 10% shares are moved "\
                             'from IPO to the Market. When RhE floats it does receive only the value of the '\
                             "president's share, and the value of the 3 shares moved when parring will be paid "\
                             "to RhE's treasury as soon as there is a railway link between Aachen and Köln via Düren.",
              },
            ],
          },
        ].freeze

        COMPANIES = [
          {
            sym: 'PWB',
            name: 'No. 1 Prinz Wilhelm-Bahn',
            value: 20,
            revenue: 5,
            desc: 'Blocks Hex E14. As director of a corporation the owner may place the first tile on this hex. '\
                  'An upgrade follows the normal track building rules. If there is still no tile on hex E14 after the '\
                  'purchase of the first 5 train, the blocking by the PWB ends.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[E14] }],
          },
          {
            sym: 'ATB',
            name: 'No. 1 Angertalbahn',
            value: 20,
            revenue: 5,
            desc: 'When acting as a director of a corporation the owner may place a tile on hex E12 for free during '\
                  'the green phase. The placement of this tile is in addition to the normal tile placement. '\
                  'The corporation needs an unblocked track link to hex E12.',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'player',
                hexes: %w[E12],
                tiles: %w[1 2 55 56 69],
                when: 'track',
                free: 'true',
                reachable: 'false',
                count: 1,
              },
            ],
          },
          {
            sym: 'KEO',
            name: 'No. 2 Konzession Essen-Osterath',
            value: 30,
            revenue: 0,
            desc: 'With the beginning of the green phase the special function case be used. As director of a '\
                  'corporation the owner may lay the special tile # 935 on hex E8 regardless whether there is a tile on '\
                  'that hex or not. Directly after the tile placement the operating corporation may place a station '\
                  'token for free on that hex (the director must use the station token with the lowest cost). '\
                  'For further details see rules section 4.2.',
            abilities: [
              {
                type: 'teleport',
                owner_type: 'player',
                tiles: %w[935],
                hexes: %w[E8],
                when: ['Phase 3', 'Phase 4'],
              },
            ],
          },
          {
            sym: 'Sz',
            name: 'No. 3 Seilzyganlage',
            value: 50,
            revenue: 15,
            desc: 'As director of a corporation the owner may place a tile on a mountain hex for free during the '\
                  "corporation's track building phase. This tile placement is in addition to the corporation's normal "\
                  "track lay and there need not be a link to the corporation's network. This function can only be used "\
                  'once during the game.',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'player',
                hexes: %w[D13 E12 E14 F11 F13 G12 G14 H13 I12 I14 J13 K2 K12],
                tiles: %w[1 2 3 4 5 6 7 8 9 23 24 25 30 55 57 58 69 930 934 937],
                when: 'track',
                free: 'true',
                reachable: 'false',
                count: 1,
              },
            ],
          },
          {
            sym: 'Tjt',
            name: 'No. 4 Trajektanstalt',
            value: 80,
            revenue: 20,
            desc: 'As director of a corporation the owner may upgrade *one* of the yellow hexes of '\
                  'Köln / Düsseldorf / Duisburg for free. This tile placement is in addition to the '\
                  "corporation's normal tile lay. The corporation may place a station marker there in the same OR "\
                  "by paying the appropriate costs. There need not be a link to the corporation's network. "\
                  'For further details see rules section 4.2.',
            abilities: [
              {
                type: 'teleport',
                owner_type: 'player',
                tiles: %w[921 922 923 924 925 926],
                hexes: %w[D9 F9 I10],
              },
            ],
          },
          {
            sym: 'NLK',
            name: 'No. 5 Niederrheinische Licht- und Kraftwerke',
            value: 120,
            revenue: 25,
            abilities: [{ type: 'shares', shares: 'GVE_1' }],
            desc: 'The player who purchased the Niederrheinische Licht- und Kraftwerke immediately receives a 10% '\
                  'share of the GVE for free. In order to float the GVE only 40% of the GVE needs to be sold from the '\
                  'Initial Offering.',
          },
          {
            sym: 'RhE',
            name: "No. 6 Director's Certificate of Rheinischen Eisenbahngesellschaft",
            value: 140,
            revenue: 0,
            abilities: [
              { type: 'shares', shares: 'RhE_0' },
              { type: 'close', when: 'par', corporation: 'RhE' },
            ],
            desc: 'The player who purchased this must immediately set the starting value for the RhE. '\
                  'Three 10% shares of the RhE will be placed in the Bank Pool. The Bank will pay the par '\
                  'value of the three 10% shares to the RhE treasury as soon as there is a track link from '\
                  'Köln to Aachen via Düren.',
          },
        ].freeze

        LAYOUT = :pointy

        AXES = { x: :number, y: :letter }.freeze

        def num_trains(train)
          return train[:num] unless train[:name] == '2'

          optional_2_train ? 8 : 7
        end

        def optional_2_train
          @optional_rules&.include?(:optional_2_train)
        end

        def optional_lower_starting_capital
          @optional_rules&.include?(:lower_starting_capital)
        end

        def optional_promotion_tiles
          @optional_rules&.include?(:promotion_tiles)
        end

        def optional_ratingen_variant
          @optional_rules&.include?(:ratingen_variant)
        end

        def optional_hexes
          base_map
        end

        def game_companies
          # Private 1 is different in base game and in Ratingen Variant
          all = self.class::COMPANIES
          return all.reject { |c| c[:sym] == 'ATB' } unless optional_ratingen_variant

          all.reject { |c| c[:sym] == 'PWB' }
        end

        def optional_tiles
          remove_tiles(%w[Essen-0 949-0 950-0 932V-0 932V-1]) unless optional_promotion_tiles
          remove_tiles(%w[932-0 932-1]) if optional_promotion_tiles
          remove_tiles(%w[1910-0 1911-0]) unless optional_ratingen_variant
        end

        def remove_tiles(tiles)
          tiles.each do |ot|
            @tiles.reject! { |t| t.id == ot }
            @all_tiles.reject! { |t| t.id == ot }
          end
        end

        def init_starting_cash(players, bank)
          cash = optional_lower_starting_capital ? self.class::LOWER_STARTING_CASH : self.class::STARTING_CASH
          cash = cash[players.size]

          players.each do |player|
            bank.spend(cash, player)
          end
        end

        def kkk
          @kkk_corporation ||= corporation_by_id('KKK')
        end

        def rhe
          @rhe_corporation ||= corporation_by_id('RhE')
        end

        def setup
          kkk.shares[1].double_cert = true
          kkk.shares[2].double_cert = true

          @aachen_connection = 0

          @essen_tile ||= @tiles.find { |t| t.name == 'Essen' } if optional_promotion_tiles
          @moers_tile_gray ||= @tiles.find { |t| t.name == '950' } if optional_promotion_tiles
          @d_k_tile ||= @tiles.find { |t| t.name == '932V' } if optional_promotion_tiles
          @d_du_k_tile ||= @tiles.find { |t| t.name == '932' } unless optional_promotion_tiles
          @du_tile_gray ||= @tiles.find { |t| t.name == '949' } if optional_promotion_tiles
        end

        include StubsAreRestricted

        def after_buy_company(player, company, _price)
          super

          return unless company.id == 'RhE'

          @log << "Move 3 #{rhe.name} 10% shares to market"
          rhe.shares[1..3].each do |s|
            @share_pool.transfer_shares(s.to_bundle, @share_pool, price: 0, allow_president_change: false)
          end
        end

        def float_corporation(corporation)
          @log << "#{corporation.name} floats"

          # Corporation receives par price for all shares sold from IPO to players
          paid_to_treasury = 5

          if corporation == rhe
            @aachen_connection = rhe.par_price.price * 3
            delayed = format_currency(@aachen_connection)
            @log << "#{rhe.name} will receive #{delayed} when there is a link from Köln to Aachen via Düren"
          else
            @bank.spend(corporation.par_price.price * paid_to_treasury, corporation)
            @log << "#{corporation.name} receives #{format_currency(corporation.cash)}"
          end

          corporation.capitalization = :incremental
        end

        def ipo_name(corporation)
          return 'I/T' unless corporation

          corporation.capitalization == :incremental ? 'Treasury' : 'IPO'
        end

        def upgrades_to?(from, to, _special = false, selected_company: nil)
          # Osterath cannot be upgraded
          return false if from.name == '935'

          # Handle Moers upgrades
          return to.name == '947' if from.color == :green && from.hex.name == 'D7'
          return to.name == '950' if from.color == :brown && from.hex.name == 'D7'

          if optional_promotion_tiles
            # Essen can be upgraded to gray
            return to.name == 'Essen' if from.color == :brown && from.name == '216'

            # Dusseldorf and Cologne can be upgraded to gray 950
            return to.name == '950' if from.color == :brown && %w[F9 I10].include?(from.hex.name)

            # Duisburg can be upgraded to gray 929
            return to.name == '929' if from.color == :brown && from.hex.name == 'D9'
          elsif from.color == :brown && %w[D9 F9 I10].include?(from.hex.name)
            return to.name == '932'
          end
          # Duisburg, Dusseldorf and Cologne can be upgraded to gray 932

          super
        end

        def all_potential_upgrades(tile, tile_manifest: false, selected_company: nil)
          # Osterath cannot be upgraded
          return [] if tile.name == '935'

          upgrades = super

          return upgrades unless tile_manifest

          # Handle Moers tile manifest
          upgrades |= [@moers_tile_gray] if @moers_tile_gray && tile.name == '947'

          # Tile manifest for 216 should show Essen if promotional tiles used
          upgrades |= [@essen_tile] if @essen_tile && tile.name == '216'

          upgrades |= [@d_k_tile] if @d_k_tile && %w[927 928].include?(tile.name)
          upgrades |= [@d_du_k_tile] if @d_du_k_tile && %w[927 928 929].include?(tile.name)
          upgrades |= [@du_tile_gray] if @du_tile_gray && tile.name == '929'

          upgrades
        end

        private

        def base_map
          e10_configuration = 'border=edge:1,type:water'
          e12_configuration = 'town=revenue:0;town=revenue:0;upgrade=cost:30,terrain:mountain'
          if optional_ratingen_variant
            e10_configuration += ';stub=edge:0;stub=edge:2;city=revenue:0'
            e12_configuration += ';stub=edge:1'
          end
          {
            red: {
              ['A2'] => 'offboard=revenue:yellow_40|brown_60,hide:1,groups:Nimwegen',
              ['A4'] => 'offboard=revenue:yellow_40|brown_60,groups:Nimwegen;path=a:0,b:_0,terminal:1;'\
                        'border=edge:4,type:water',
              ['A6'] => 'offboard=revenue:yellow_40|brown_60;path=a:5,b:_0,terminal:1;border=edge:0,type:water;'\
                        'border=edge:1,type:water',
              ['A14'] => 'city=revenue:yellow_40|brown_60;path=a:0,b:_0,terminal:1',
              ['B15'] => 'city=revenue:yellow_50|brown_80;path=a:1,b:_0,terminal:1',
              ['C2'] => 'city=revenue:yellow_10|brown_30;path=a:4,b:_0,terminal:1',
              ['C14'] => 'city=revenue:10;city=revenue:10;path=a:0,b:_0,terminal:1;path=a:1,b:_1,terminal:1;'\
                         'label=+10/link',
              ['D15'] => 'city=revenue:10;city=revenue:10;path=a:0,b:_0,terminal:1;path=a:1,b:_1,terminal:1;'\
                         'label=+10/link',
              ['E2'] => 'city=revenue:yellow_20|brown_40;path=a:3,b:_0;path=a:5,b:_0',
              ['G2'] => 'city=revenue:yellow_10|brown_20;path=a:4,b:_0,terminal:1',
              ['J1'] => 'city=revenue:yellow_20|brown_30;path=a:5,b:_0,terminal:1',
              ['L1'] => 'offboard=revenue:yellow_30|brown_60;path=a:3,b:_0,terminal:1',
              %w[L3 L5 L7] => '',
              ['L9'] => 'town=revenue:10;path=a:2,b:_0;path=a:3,b:_0',
              ['L11'] => 'offboard=revenue:yellow_30|brown_70;border=edge:3,type:water;'\
                         'border=edge:4,type:water;path=a:2,b:_0',
              ['L13'] => 'offboard=revenue:yellow_30|brown_60;border=edge:1,type:water;path=a:2,b:_0',
            },
            gray: {
              %w[A8 A10 A12 B1 D1 F1 H1] => '',
              %w[F15 H15] => 'path=a:0,b:2',
              ['I4'] => 'path=a:0,b:3',
              ['J15'] => 'city=revenue:yellow_20|brown_40;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
              ['K14'] => 'path=a:1,b:3',
            },
            white: {
              ['B5'] => 'border=edge:3,type:water;border=edge:4,type:water',
              ['B7'] => 'border=edge:0,type:water;border=edge:1,type:water;border=edge:5,type:water',
              ['B9'] => 'city=revenue:0;border=edge:0,type:water',
              %w[B11 D3 D5 E4 F3 F7 G4 G8 H3 H5 H7 I2 I8 J5 J7 K8] => '',
              %w[B13 E8 F5 J3] => 'town=revenue:0;town=revenue:0',
              %w[C4 I6 K4] => 'town=revenue:0',
              ['C6'] => 'town=revenue:0;border=edge:3,type:water',
              ['C8'] => 'stub=edge:3;upgrade=cost:30,terrain:water;border=edge:2,type:water;border=edge:3,type:water;'\
                        'border=edge:4,type:water',
              ['C10'] => 'town=revenue:0;town=revenue:0;border=edge:1,type:water',
              %w[C12 D11] => 'city=revenue:0;city=revenue:0;label=OO',
              ['D13'] => 'city=revenue:0;upgrade=cost:30,terrain:mountain;label=Y',
              ['E6'] => 'city=revenue:0;label=Y',
              ['E8'] => 'town=revenue:0;town=revenue:0;border=edge:4,type:water',
              ['E10'] => e10_configuration,
              ['E12'] => e12_configuration,
              %w[E14 J13] => 'upgrade=cost:30,terrain:mountain',
              %w[F11 G14 H13] => 'upgrade=cost:60,terrain:mountain',
              ['G10'] => 'town=revenue:0;town=revenue:0;border=edge:0,type:water;border=edge:1,type:water',
              ['G12'] => 'city=revenue:0;city=revenue:10;upgrade=cost:30,terrain:mountain;path=a:4,b:_1;label=OO',
              ['H9'] => 'town=revenue:0;border=edge:3,type:water;border=edge:4,type:water',
              ['H11'] => 'border=edge:1,type:water',
              ['I12'] => 'town=revenue:0;upgrade=cost:30,terrain:mountain',
              ['J11'] => 'border=edge:0,type:water;border=edge:1,type:water',
              ['K10'] => 'city=revenue:0;border=edge:3,type:water;border=edge:4,type:water',
              ['K12'] => 'town=revenue:0;upgrade=cost:30,terrain:mountain;border=edge:0,type:water;'\
                         'border=edge:1,type:water',
              %w[G8 J9] => 'border=edge:4,type:water',
            },
            yellow: {
              ['B3'] => 'path=a:3,b:5',
              ['D9'] => 'city=revenue:20;city=revenue:30;city=revenue:30;upgrade=cost:30,terrain:water;path=a:0,b:_0;'\
                        'path=a:3,b:_1;path=a:5,b:_2;label=DU',
              ['F9'] => 'city=revenue:20;city=revenue:30;city=revenue:30;upgrade=cost:30,terrain:water;path=a:0,b:_0;'\
                        'path=a:4,b:_1;path=a:5,b:_2;label=D',
              ['F13'] => 'city=revenue:30;city=revenue:30;upgrade=cost:30,terrain:mountain;path=a:1,b:_0;'\
                         'path=a:_0,b:2;path=a:3,b:_1;path=a:_1,b:5;label=Y',
              ['G6'] => 'city=revenue:0;city=revenue:0;path=a:0,b:_0;path=a:2,b:_1;label=OO',
              ['I10'] => 'city=revenue:30;city=revenue:30;city=revenue:20;upgrade=cost:30,terrain:water;'\
                         'path=a:0,b:_0;path=a:2,b:_1;path=a:3,b:_2;label=K',
              ['I14'] => 'upgrade=cost:60,terrain:mountain;path=a:3,b:5',
              ['K2'] => 'city=revenue:20;upgrade=cost:30,terrain:mountain;path=a:3,b:_0;path=a:4,b:_0;label=AC',
              ['K6'] => 'city=revenue:20;path=a:1,b:_0;path=a:4,b:_0',
            },
            green: {
              ['D7'] => 'city=revenue:0',
            },
          }
        end
      end
    end
  end
end
