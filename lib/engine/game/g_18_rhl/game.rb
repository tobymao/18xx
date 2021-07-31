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

        GAME_END_CHECK = { bank: :full_or }.freeze

        # Move down one step for a whole block, not per share
        SELL_MOVEMENT = :down_block

        # Cannot sell until operated
        SELL_AFTER = :operate

        # Sell zero or more, then Buy zero or one
        SELL_BUY_ORDER = :sell_buy

        # New track must be usable, or upgrade city value
        TRACK_RESTRICTION = :semi_restrictive

        # Cannot buy other corp trains during emergency buy (rule 13.2)
        EBUY_OTHER_VALUE = false

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'remove_tile_block' => ['Remove tile block', 'Hex E12 can now be upgraded to yellow'],
        ).freeze

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
            'code' => 'city=revenue:40,slots:3;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=D;'\
                      'upgrade=cost:50,terrain:river;icon=image:18_rhl/trajekt,sticky:0',
          },
          '922' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:3;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=D;'\
                      'upgrade=cost:50,terrain:river;icon=image:18_rhl/trajekt,sticky:0',
          },
          '923' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=K;'\
                      'upgrade=cost:50,terrain:river;icon=image:18_rhl/trajekt,sticky:0',
          },
          '924' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:3;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=K;'\
                      'upgrade=cost:50,terrain:river;icon=image:18_rhl/trajekt,sticky:0',
          },
          '925' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:3;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=DU;'\
                      'upgrade=cost:50,terrain:river;icon=image:18_rhl/trajekt,sticky:0',
          },
          '926' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=DU;'\
                      'upgrade=cost:50,terrain:river;icon=image:18_rhl/trajekt,sticky:0',
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
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;label=Y',
          },
          '935' =>
          {
            'count' => 1,
            'color' => 'orange',
            'code' => 'city=revenue:20,loc:center;town=revenue:10,loc:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_1;'\
                      'path=a:_1,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Osterath',
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
          'A2' => 'Nimwegen',
          'A6' => 'Arnheim',
          'A14' => 'Hamburg Münster',
          'B9' => 'Wesel',
          'B15' => 'Berlin Minden',
          'C2' => 'Boxtel',
          'C12' => 'Herne Gelsenkirchen',
          'C14' => 'Östliches Ruhrgebiet',
          'D7' => 'Moers',
          'D9' => 'Duisburg',
          'D11' => 'Oberhausen Mülheim',
          'D13' => 'Essen',
          'E2' => 'Venio',
          'E6' => 'Krefeld',
          'E12' => 'Ratingen',
          'F9' => 'Neuss Düsseldorf',
          'F13' => 'Elberfeld Barmen',
          'G2' => 'Roermond',
          'G6' => 'M-Gladbach Rheydt',
          'G12' => 'Remshcheid Solingen',
          'I10' => 'Köln Deutz',
          'K2' => 'Aachen',
          'K6' => 'Düren',
          'K10' => 'Bonn',
          'J1' => 'Maastrict',
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
          },
          {
            name: '6',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            num: 6,
            price: 600,
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '8',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 8, 'visit' => 99 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
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
            logo: '18_rhl/ADR',
            simple_logo: '18_rhl/ADR.alt',
            color: :green,
            coordinates: 'K2',
            always_market_price: true,
            max_ownership_percent: 100,
          },
          {
            name: 'Bergisch-Märkische Eisenbahngesell.',
            sym: 'BME',
            float_percent: 50,
            tokens: [0, 60, 80, 100],
            logo: '18_rhl/BME',
            simple_logo: '18_rhl/BME.alt',
            color: :brown,
            coordinates: 'F13',
            city: 1,
            always_market_price: true,
            max_ownership_percent: 100,
          },
          {
            name: 'Cöln-Mindener Eisenbahngesellschaft',
            sym: 'CME',
            float_percent: 50,
            tokens: [0, 60, 80, 100],
            color: '#CD5C5C',
            logo: '18_rhl/CME',
            simple_logo: '18_rhl/CME.alt',
            coordinates: 'I10',
            city: 2,
            always_market_price: true,
            max_ownership_percent: 100,
          },
          {
            name: 'Düsseldorf Elberfelder Eisenbahn',
            sym: 'DEE',
            float_percent: 50,
            tokens: [0, 60],
            logo: '18_rhl/DEE',
            simple_logo: '18_rhl/DEE.alt',
            color: :yellow,
            text_color: :black,
            coordinates: 'F9',
            city: 1,
            always_market_price: true,
            max_ownership_percent: 100,
          },
          {
            name: 'Krefeld-Kempener Eisenbahn',
            sym: 'KKK',
            float_percent: 60,
            tokens: [0, 60],
            # The 2nd share decided share percentage for shares
            shares: [20, 10, 20, 20, 10, 10, 10],
            logo: '18_rhl/KKK',
            simple_logo: '18_rhl/KKK.alt',
            color: :orange,
            text_color: :black,
            coordinates: 'D7',
            abilities: [
              {
                type: 'base',
                description: 'Two double (20%) certificates',
                desc_detail: 'The first two (non-president) shares sold from IPO are double (20%) certificates',
              },
            ],
            always_market_price: true,
            max_ownership_percent: 100,
          },
          {
            name: 'Gladbach-Venloer Eisenbahn',
            sym: 'GVE',
            float_percent: 50,
            tokens: [0, 60],
            logo: '18_rhl/GVE',
            simple_logo: '18_rhl/GVE.alt',
            color: :gray,
            coordinates: 'G6',
            city: 1,
            always_market_price: true,
            max_ownership_percent: 100,
          },
          {
            name: 'Cöln-Crefelder Eisenbahn',
            sym: 'CCE',
            float_percent: 50,
            tokens: [0, 0, 80],
            color: :blue,
            logo: '18_rhl/CCE',
            simple_logo: '18_rhl/CCE.alt',
            coordinates: %w[E6 I10],
            city: 1,
            abilities: [
              {
                type: 'base',
                description: 'Two home stations (Köln & Krefeld)',
              },
            ],
            always_market_price: true,
            max_ownership_percent: 100,
          },
          {
            name: 'Rheinische Eisenbahngesellschaft',
            sym: 'RhE',
            float_percent: 50,
            tokens: [0, 60, 80, 100],
            color: :purple,
            logo: '18_rhl/RhE',
            simple_logo: '18_rhl/RhE.alt',
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
            always_market_price: true,
            max_ownership_percent: 100,
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
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[E12] },
                        {
                          type: 'tile_lay',
                          owner_type: 'player',
                          hexes: %w[E12],
                          tiles: %w[1 2 55 56 69],
                          free: true,
                          reachable: false,
                          special: true,
                          count: 1,
                          when: %w[track owning_player_or_turn],
                        }],
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
                count: 1,
                when: %w[track owning_player_or_turn],
              },
            ],
          },
          {
            sym: 'Szl',
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
                tiles: %w[1 2 3 4 5 6 7 8 9 23 24 25 30 55 56 57 58 69 930 934 937],
                free: true,
                reachable: false,
                count: 1,
                when: %w[track owning_player_or_turn],
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
                count: 1,
                when: %w[track owning_player_or_turn],
              },
            ],
          },
          {
            sym: 'NLK',
            name: 'No. 5 Niederrheinische Licht- und Kraftwerke',
            value: 120,
            revenue: 25,
            abilities: [{ type: 'shares', shares: 'GVE_1' },
                        # block_partition has no effect, except it makes it possible to show Rhine in hex D9, F9 and I10
                        # (the three Rhine Metropolis hexes). When upgrading these hexes to green the partition is removed.
                        {
                          type: 'blocks_partition',
                          partition_type: 'water',
                        }],
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

        EASTERN_RUHR_CONNECTION_CHECK = %w[C12 D13 E14].freeze

        EASTERN_RUHR_HEXES = %w[C14 D15].freeze

        NIMWEGEN_ARNHEIM_OFFBOARD_HEXES = %(A4 A6).freeze

        OSTEROTH_POTENTIAL_TILE_UPGRADES_FROM = %w[1 2 55 56 69].freeze

        OUT_TOKENED_HEXES = %w[A14 B15 C2].freeze

        RATINGEN_HEX = 'E12'

        RGE_HEXES = %w[A4 A6 L11 L13].freeze

        RHINE_METROPOLIS_HEXES = %w[D9 F9 I10].freeze

        SOUTHERN_OFFBOARD_HEXES = %w[L1 L11 L13].freeze

        def aachen_hex
          @aachen_hex ||= hex_by_id('K2')
        end

        def cologne_hex
          @cologne_hex ||= hex_by_id('I10')
        end

        def duren_hex
          @duren_hex ||= hex_by_id('K6')
        end

        def duisburg_hex
          @duisburg_hex ||= hex_by_id('D9')
        end

        def dusseldorf_hex
          @dusseldorf_hex ||= hex_by_id('F9')
        end

        def roermund_hex
          @roermund_hex ||= hex_by_id('G2')
        end

        def yellow_block_hex
          @yellow_block_hex ||= hex_by_id(RATINGEN_HEX)
        end

        def game_trains
          trains = self.class::TRAINS
          return trains unless optional_ratingen_variant

          # Inject remove_tile_block event
          trains.each do |t|
            next unless t[:name] == '3'

            t[:events] = [{ 'type' => 'remove_tile_block' }]
          end
          trains
        end

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

        def stock_round
          @newly_floated = []
          G18Rhl::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G18Rhl::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          G18Rhl::Round::Operating.new(self, [
            G18Rhl::Step::Bankrupt,
            Engine::Step::HomeToken,
            G18Rhl::Step::SpecialToken, # Must be before any track lay (due to private No. 4)
            G18Rhl::Step::SpecialTrack,
            G18Rhl::Step::Track,
            G18Rhl::Step::RheBonusCheck,
            Engine::Step::Token,
            Engine::Step::Route,
            G18Rhl::Step::Dividend,
            Engine::Step::DiscardTrain,
            G18Rhl::Step::BuyTrain,
          ], round_num: round_num)
        end

        def priority_deal_player
          players_with_max_cash.size > 1 ? players_with_max_cash.first : super
        end

        def players_with_max_cash
          max_cash = @players.max_by(&:cash).cash
          @players.select { |p| p.cash == max_cash }
        end

        def reorder_players(_order = nil, log_player_order: false)
          max_cash_players = players_with_max_cash
          if max_cash_players.one?
            @players.rotate!(@players.index(max_cash_players.first))
            @log << "#{@players.first.name} has priority deal as having the most cash"
          else
            player = @players.reject(&:bankrupt)[@round.entity_index]
            @players.rotate!(@players.index(player))
            @log << "#{@players.first.name} has priority deal as being left of last to act, as several had the most cash"
          end
        end

        def cce
          @cce_corporation ||= corporation_by_id('CCE')
        end

        def kkk
          @kkk_corporation ||= corporation_by_id('KKK')
        end

        def rhe
          @rhe_corporation ||= corporation_by_id('RhE')
        end

        def prinz_wilhelm_bahn
          return if optional_ratingen_variant

          @prinz_wilhelm_bahn ||= company_by_id('PWB')
        end

        def angertalbahn
          return unless optional_ratingen_variant

          @angertalbahn ||= company_by_id('ATB')
        end

        def konzession_essen_osterath
          @konzession_essen_osterath ||= company_by_id('KEO')
        end

        def seilzuganlage
          @seilzuganlage ||= company_by_id('Szl')
        end

        def trajektanstalt
          @trajektanstalt ||= company_by_id('Tjt')
        end

        def setup
          kkk.shares[2].double_cert = true
          kkk.shares[3].double_cert = true

          @aachen_duren_cologne_link_bonus = 0
          @eastern_ruhr_connections = []
          @newly_floated = []

          @essen_tile ||= @tiles.find { |t| t.name == 'Essen' } if optional_promotion_tiles
          @moers_tile_gray ||= @tiles.find { |t| t.name == '950' } if optional_promotion_tiles
          @d_k_tile ||= @tiles.find { |t| t.name == '932V' } if optional_promotion_tiles
          @d_du_k_tile ||= @tiles.find { |t| t.name == '932' } unless optional_promotion_tiles
          @du_tile_gray ||= @tiles.find { |t| t.name == '949' } if optional_promotion_tiles
          @osteroth_tile ||= @tiles.find { |t| t.name == '935' }

          @variable_placement = (rand % 9) + 1

          # Put out K tokens
          @k = Corporation.new(
            sym: 'K',
            name: 'Coal',
            logo: '18_rhl/K',
            simple_logo: '18_rhl/K.alt',
            tokens: [0, 0, 0, 0],
          )
          @k.owner = @bank
          place_free_token(@k, 'C14', 1)
          place_free_token(@k, 'D15', 0)
          extra_coal_mine = hex_by_id(variable_coal_mine)
          extra_coal_mine.tile.icons << Part::Icon.new('../logos/18_rhl/K')
          @log << "Variable coal mine added to #{extra_coal_mine.name}"

          @s = Corporation.new(
            sym: 'S',
            name: 'Steel',
            logo: '18_rhl/S',
            simple_logo: '18_rhl/S.alt',
            tokens: [0, 0, 0, 0],
          )
          @s.owner = @bank
          place_free_token(@s, 'C14', 0)
          place_free_token(@s, 'D15', 1)
          extra_steel_mill = hex_by_id(variable_steel_mill).tile
          extra_steel_mill.icons << Part::Icon.new('../logos/18_rhl/S')
          @log << "Variable steel mill added to #{extra_steel_mill.name}"
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
          if brown_phase?
            # When floated in phase 5 or later, do a "normal" float (ie 100% cap, be fullcap)
            # and move unsold shares to market.
            super

            @log << 'Move remaining IPO shares to market'
            corporation.shares.each do |s|
              @share_pool.transfer_shares(s.to_bundle, @share_pool, price: 0, allow_president_change: false)
            end
            return
          end

          @log << "#{corporation.name} floats"

          # For floats before phase 5, corporation receives par price for all shares sold from IPO to players.
          # The remaining shares end up in Treasury, and corporation becomes incremental.
          paid_to_treasury = corporation == kkk ? 6 : 5

          if corporation == rhe
            @aachen_duren_cologne_link_bonus = rhe.par_price.price * 3
            delayed = format_currency(@aachen_duren_cologne_link_bonus)
            @log << "#{rhe.name} will receive #{delayed} when there is a link from Köln to Aachen via Düren"
          else
            @bank.spend(corporation.par_price.price * paid_to_treasury, corporation)
            @log << "#{corporation.name} receives #{format_currency(corporation.cash)}"
          end

          corporation.capitalization = :incremental

          # Corporations floated before phase 5 will increase one step at end of current SR
          @newly_floated << corporation
        end

        def handle_share_price_increase_for_newly_floated_corporations
          @newly_floated.each do |corp|
            prev = corp.share_price.price

            stock_market.move_up(corp)
            @log << "The share price of the newly floated #{corp.name} increases" if prev != corp.share_price.price
            log_share_price(corp, prev)
          end
          @newly_floated = []
        end

        def ipo_name(corporation)
          return 'I/T' unless corporation

          corporation.capitalization == :incremental ? 'Treasury' : 'IPO'
        end

        class WithNameAdapter
          def name
            'Receivership'
          end
        end

        def acting_for_entity(entity)
          return super if entity.owned_by_player?

          WithNameAdapter.new
        end

        def place_home_token(corporation)
          return super unless corporation == cce
          return if corporation.tokens.first&.used == true

          place_free_token(cce, 'E6', 0, silent: false)
          place_free_token(cce, 'I10', 1, silent: false)
        end

        def start_trajektanstalt_teleport
          @trajektanstalt_teleport = current_entity
        end

        def complete_trajektanstalt_teleport
          @trajektanstalt_teleport = nil
        end

        def tile_lays(entity)
          return super unless @trajektanstalt_teleport == entity

          # The Trajektanstalt teleport consumes the regular tile lay so to allow
          # for the current entity to also do a normalt tile lay (after the optional
          # tokening) we give it an extra tile lay or upgrade. Note! This extra
          # tile lay will be replaced with normal (one lay/upgrade) as soon as current
          # entity has completed its current OR.
          [{ lay: true, upgrade: true }, { lay: true, upgrade: true }]
        end

        def upgrades_to?(from, to, _special = false, selected_company: nil)
          # Osterath cannot be upgraded
          return false if from.name == '935'

          # Private No. 2 allows tile 935 to be put on E8 regardless
          return true if from.hex.name == 'E8' && to.name == '935' && selected_company == konzession_essen_osterath

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

          return super unless optional_ratingen_variant

          # Hex E10 have special tile for upgrade to yellow, and green, and no brown
          if from.hex.name == 'E10'
            case from.color
            when :white
              return to.name == '1910'
            when :yellow
              return to.name == '1911'
            else
              return false
            end
          end

          # Hex E12 is blocked for upgrade in yellow phase
          return super if from.hex.name != RATINGEN_HEX || phase.name != '2'

          raise GameError, "Cannot place a tile in #{from.hex.name} until green phase"
        end

        def all_potential_upgrades(tile, tile_manifest: false, selected_company: nil)
          # Osterath cannot be upgraded
          return [] if tile.name == '935'

          upgrades = super

          return upgrades unless tile_manifest

          # Handle potential upgrades to Osteroth tile
          upgrades |= [@osteroth_tile] if OSTEROTH_POTENTIAL_TILE_UPGRADES_FROM.include?(tile.name)

          # Tile manifest for 947 should show Moers tile if Moers tile used
          upgrades |= [@moers_tile_gray] if @moers_tile_gray && tile.name == '947'

          # Tile manifest for 216 should show Essen tile if Essen tile used
          upgrades |= [@essen_tile] if @essen_tile && tile.name == '216'

          # Show correct potential upgrades for Rhine Metropolis hexes
          upgrades |= [@d_k_tile] if @d_k_tile && %w[927 928].include?(tile.name)
          upgrades |= [@d_du_k_tile] if @d_du_k_tile && %w[927 928 929].include?(tile.name)
          upgrades |= [@du_tile_gray] if @du_tile_gray && tile.name == '929'

          upgrades
        end

        def legal_tile_rotation?(_entity, hex, tile)
          return legal_if_stubbed?(hex, tile) unless tile.name == '1910'

          # Need special handling - tile 1910 must match both stubs of base hex
          hex.tile.stubs.map(&:edge) == tile.exits
        end

        def hex_blocked_by_ability?(entity, ability, hex)
          return false if entity.player == ability.owner.player && (hex.name == 'E14' || hex == yellow_block_hex)

          super
        end

        def event_remove_tile_block!
          @log << "Hex #{RATINGEN_HEX} is now possible to upgrade to yellow"
          yellow_block_hex.tile.icons.reject! { |i| i.name == 'green_hex' }
        end

        def check_distance(route, visits)
          raise GameError, 'Route cannot begin/end in a town' if visits.first.town? || visits.last.town?

          if (metropolis_name, rhine_side = illegal_double_visit_yellow_rhine_metropolis?(visits))
            raise GameError, "A route cannot visit #{metropolis_name} side of Rhine Metropolis #{rhine_side} twice"
          end

          if visits.count { |v| EASTERN_RUHR_HEXES.include?(v.hex.name) } > 1
            raise GameError, 'A route cannot both begin and end at Eastern Ruhr off-board hexes'
          end

          if visits.count { |v| NIMWEGEN_ARNHEIM_OFFBOARD_HEXES.include?(v.hex.name) } > 1
            raise GameError, 'A route cannot both begin and end at the Nimwegen and Arnheim off-board hexes'
          end

          if visits.count { |v| SOUTHERN_OFFBOARD_HEXES.include?(v.hex.name) } > 1
            raise GameError, 'A route cannot both begin and end at the Southern off-board hexes'
          end

          return super unless route.train.name == '8'

          if visits.none? { |v| RGE_HEXES.include?(v.hex.name) }
            raise GameError, 'Route for 8 trains must begin/end in an RGE hex'
          end

          return super unless visits.find { |v| !RGE_HEXES.include?(v.hex.name) && v.hex.tile.color == :red }

          raise GameError, 'Route for 8 trains cannot include any off-board hexes besides the RGE ones'
        end

        def revenue_for(route, stops)
          revenue = super
          revenue_info(route, stops).each { |b| revenue += b[:revenue] }

          revenue
        end

        def revenue_str(route)
          stops = route.stops
          stop_hexes = stops.map(&:hex)
          str = route.hexes.map do |h|
            stop_hexes.include?(h) ? h&.name : "(#{h&.name})"
          end.join('-')

          revenue_info(route, stops).map { |b| b[:description] }.compact.each { |d| str += " + #{d}" }

          str
        end

        def revenue_info(route, stops)
          corporation = route.train.owner
          [off_board_out_tokened_penalty(route, stops, corporation),
           montan_bonus(route, stops),
           eastern_ruhr_area_bonus(stops),
           iron_rhine_bonus(stops, corporation),
           trajekt_usage_penalty(route, stops),
           rheingold_express_bonus(route, stops),
           ratingen_bonus(route, stops)]
        end

        def aachen_duren_cologne_link_checkable?
          @aachen_duren_cologne_link_bonus.positive?
        end

        def aachen_duren_cologne_link_established?
          return unless aachen_duren_cologne_link_checkable?
          return if loading

          duren_aachen = false
          duren_cologne = false

          @corporations.select(&:operated?).each do |corp|
            duren_aachen ||= check_connections(corp, aachen_hex)
            duren_cologne ||= check_connections(corp, cologne_hex)
          end
          duren_aachen && duren_cologne
        end

        def aachen_duren_cologne_link_established!
          @log << 'A link between Aachen and Köln, via Düren, has been established!'
          @log << "#{rhe.name} adds #{format_currency(@aachen_duren_cologne_link_bonus)} to its treasury"
          @bank.spend(@aachen_duren_cologne_link_bonus, rhe)
          @aachen_duren_cologne_link_bonus = 0
        end

        def eastern_ruhr_connection_check(hex)
          return if !EASTERN_RUHR_CONNECTION_CHECK.include?(hex.name) || @eastern_ruhr_connections.size == 4

          [['C12', 4], ['D13', 3], ['D13', 4], ['E14', 3]].each do |check_hex, edge|
            next unless check_hex == hex.name
            next if @eastern_ruhr_connections.include?([check_hex, edge])
            next unless hex.tile.exits.include?(edge)

            @log << 'New link to Eastern Ruhr established'
            @eastern_ruhr_connections << [check_hex, edge]
          end
        end

        def potential_icon_cleanup(tile)
          # FIXME: Sticky:0 does not seem to work so remove trajekt icon manually
          remove_trajekt_icon(tile) if RHINE_METROPOLIS_HEXES.include?(tile.hex.id) && tile.color == :brown
        end

        def shares_for_presidency_swap(shares, num_shares)
          # The shares to exchange might contain a double share.
          # If so, return that unless more than 2 certificates.
          twenty_percent = shares.find(&:double_cert)
          return super unless twenty_percent
          return [twenty_percent] if shares.size <= num_shares && twenty_percent

          super(shares - [twenty_percent], num_shares)
        end

        private

        def base_map
          e10_configuration = 'border=edge:1,type:impassable,color:blue'
          e12_configuration = 'town=revenue:0;town=revenue:0;upgrade=cost:30,terrain:mountain'
          if optional_ratingen_variant
            e10_configuration += ';stub=edge:0;stub=edge:2;city=revenue:0'
            e12_configuration += ';stub=edge:1;icon=image:1893/green_hex;icon=image:18_rhl/white_wooden_cube,sticky:1'
          end
          {
            red: {
              ['A2'] => 'offboard=revenue:yellow_40|brown_60,hide:1,groups:NorthWest',
              ['A4'] => 'offboard=revenue:yellow_40|brown_60,groups:NorthWest;path=a:0,b:_0,terminal:1;'\
                        'border=edge:4,type:impassable,color:blue;icon=image:18_rhl/RGE',
              ['A6'] => 'offboard=revenue:yellow_40|brown_60,groups:NorthWest;path=a:5,b:_0,terminal:1;'\
                        'border=edge:0,type:impassable,color:blue;border=edge:1,type:impassable,color:blue;icon=image:18_rhl/RGE',
              ['A14'] => 'city=revenue:yellow_40|brown_60;path=a:0,b:_0,terminal:1',
              ['B15'] => 'city=revenue:yellow_50|brown_80;path=a:1,b:_0,terminal:1',
              ['C2'] => 'city=revenue:yellow_10|brown_30;path=a:4,b:_0,terminal:1',
              ['C14'] => 'city=revenue:10;city=revenue:10;path=a:0,b:_0,terminal:1;path=a:1,b:_1,terminal:1;'\
                         'icon=image:18_rhl/ERh',
              ['D15'] => 'city=revenue:10;city=revenue:10;path=a:0,b:_0,terminal:1;path=a:1,b:_1,terminal:1;'\
                         'label=+10/link;icon=image:18_rhl/ERh',
              ['E2'] => 'city=revenue:yellow_20|brown_40;path=a:3,b:_0;path=a:5,b:_0',
              ['G2'] => 'city=revenue:yellow_10|brown_20,groups:Roermond;path=a:4,b:_0,terminal:1',
              ['H1'] => 'offboard=revenue:yellow_10|brown_20,hide:1,groups:Roermond;icon=image:18_rhl/ERh',
              ['J1'] => 'offboard=revenue:yellow_10|brown_30;path=a:5,b:_0,terminal:1',
              ['L1'] => 'offboard=revenue:yellow_30|brown_60;path=a:3,b:_0,terminal:1',
              %w[L3 L5 L7] => '',
              ['L9'] => 'town=revenue:10;path=a:2,b:_0;path=a:3,b:_0',
              ['L11'] => 'offboard=revenue:yellow_30|brown_70;border=edge:3,type:impassable,color:blue;'\
                         'border=edge:4,type:impassable,color:blue;path=a:2,b:_0;icon=image:18_rhl/RGE',
              ['L13'] => 'offboard=revenue:yellow_30|brown_60;border=edge:1,type:impassable,color:blue;path=a:2,b:_0;'\
                         'icon=image:18_rhl/RGE',
            },
            gray: {
              %w[A8 A10 A12 B1 D1 F1] => '',
              %w[F15 H15] => 'path=a:0,b:2',
              ['I4'] => 'path=a:0,b:3',
              ['J15'] => 'city=revenue:yellow_20|brown_40,loc:1;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                         'icon=image:../logos/18_rhl/S',
              ['K14'] => 'path=a:1,b:3',
            },
            white: {
              ['B5'] => 'border=edge:3,type:impassable,color:blue;border=edge:4,type:impassable,color:blue',
              ['B7'] => 'border=edge:0,type:impassable,color:blue;border=edge:1,type:impassable,color:blue;'\
                        'border=edge:5,type:impassable,color:blue',
              ['B9'] => 'city=revenue:0;border=edge:0,type:water',
              %w[B11 D3 D5 E4 F3 F7 G4 G8 H3 H5 H7 I2 I8 J5 J7 K8] => '',
              %w[B13 E8 F5 J3] => 'town=revenue:0;town=revenue:0',
              %w[C4 I6 K4] => 'town=revenue:0',
              ['C6'] => 'town=revenue:0;border=edge:3,type:impassable,color:blue',
              ['C8'] => 'stub=edge:3;upgrade=cost:30,terrain:water;border=edge:2,type:impassable,color:blue;'\
                        'border=edge:3,type:water;border=edge:4,type:impassable,color:blue',
              ['C10'] => 'town=revenue:0;town=revenue:0;border=edge:1,type:impassable,color:blue',
              %w[C12 D11] => 'city=revenue:0;city=revenue:0;label=OO',
              ['D13'] => 'city=revenue:0;upgrade=cost:30,terrain:mountain;label=Y',
              ['E6'] => 'city=revenue:0;label=Y',
              ['E8'] => 'town=revenue:0;town=revenue:0;border=edge:4,type:impassable,color:blue',
              ['E10'] => e10_configuration,
              ['E12'] => e12_configuration,
              %w[E14 J13] => 'upgrade=cost:30,terrain:mountain',
              %w[F11 G14 H13] => 'upgrade=cost:60,terrain:mountain',
              ['G10'] => 'town=revenue:0;town=revenue:0;border=edge:0,type:impassable,color:blue;'\
                         'border=edge:1,type:impassable,color:blue',
              ['G12'] => 'city=revenue:0;city=revenue:10;upgrade=cost:30,terrain:mountain;path=a:4,b:_1;label=OO',
              ['H9'] => 'town=revenue:0;border=edge:3,type:impassable,color:blue;border=edge:4,type:impassable,color:blue',
              ['H11'] => 'border=edge:1,type:impassable,color:blue',
              ['I12'] => 'town=revenue:0;upgrade=cost:30,terrain:mountain',
              ['J11'] => 'border=edge:0,type:impassable,color:blue;border=edge:1,type:impassable,color:blue',
              ['K10'] => 'city=revenue:0;border=edge:3,type:impassable,color:blue;border=edge:4,type:impassable,color:blue',
              ['K12'] => 'town=revenue:0;upgrade=cost:30,terrain:mountain;border=edge:0,type:impassable,color:blue;'\
                         'border=edge:1,type:impassable,color:blue',
              %w[G8 J9] => 'border=edge:4,type:impassable,color:blue',
            },
            yellow: {
              ['B3'] => 'path=a:3,b:5',
              ['D9'] => 'city=revenue:20;city=revenue:30;city=revenue:30;upgrade=cost:30,terrain:water;path=a:0,b:_0;'\
                        'path=a:3,b:_1;path=a:5,b:_2;label=DU;partition=a:0,b:3,type:water',
              ['F9'] => 'city=revenue:20;city=revenue:30,loc:3.5;city=revenue:30;upgrade=cost:30,terrain:water;path=a:0,b:_0;'\
                        'path=a:4,b:_1;path=a:5,b:_2;label=D;partition=a:0,b:3,type:water',
              ['F13'] => 'city=revenue:30;city=revenue:30;upgrade=cost:30,terrain:mountain;path=a:1,b:_0;'\
                         'path=a:_0,b:2;path=a:3,b:_1;path=a:_1,b:5;label=Y',
              ['G6'] => 'city=revenue:20;city=revenue:20;path=a:0,b:_0;path=a:2,b:_1;label=OO',
              ['I10'] => 'city=revenue:30;city=revenue:30;city=revenue:20;upgrade=cost:30,terrain:water;'\
                         'path=a:0,b:_0;path=a:2,b:_1;path=a:3,b:_2;label=K;partition=a:0,b:3,type:water',
              ['I14'] => 'upgrade=cost:60,terrain:mountain;path=a:3,b:5',
              ['K2'] => 'city=revenue:20;upgrade=cost:30,terrain:mountain;path=a:3,b:_0;path=a:4,b:_0;label=AC',
              ['K6'] => 'city=revenue:20;path=a:1,b:_0;path=a:4,b:_0',
            },
            green: {
              ['D7'] => 'city=revenue:0;icon=image:../logos/18_rhl/K',
            },
          }
        end

        def variable_coal_mine
          case @variable_placement
          when 1, 7
            'J3'
          when 2
            'K4'
          when 3, 4
            'D9'
          when 5, 6
            'C12'
          when 8, 9
            'D11'
          end
        end

        def variable_steel_mill
          case @variable_placement
          when 1, 3, 5, 8
            'E6'
          when 2, 6, 9
            'D9'
          when 4, 7
            'D13'
          end
        end

        def brown_phase?
          @phase.name.to_i >= 5
        end

        def place_free_token(corporation, hex_name, city_number, silent: true)
          hex = hex_by_id(hex_name).tile

          # If tile has been upgraded to green - then it is just one city with slots
          city_number = 0 if hex.cities.one?
          hex.cities[city_number].place_token(corporation, corporation.next_token, free: true)
          @log << "#{corporation.name} places a token on #{hex_name}" unless silent
        end

        def illegal_double_visit_yellow_rhine_metropolis?(visits)
          # For yellow tiles in the three Rhine Metropolis hexes, the hexes are divided into
          # a West and an East part, where one of the sides has two cities while the other
          # has one. It is not allowed to have a route that include both the cities on one side
          # but it is allowed to have a route that includes one city from each side of the hex.

          yellow_rhine_metropolis_visits = visits.select do |v|
            RHINE_METROPOLIS_HEXES.include?(v.hex.name) &&
                              v.hex.tile.color == :yellow
          end
          return unless yellow_rhine_metropolis_visits.size > 1

          yellow_rhine_metropolis_visits.map! { |v| [v.hex.name, visit_on_west_side?(v)] }

          found = nil
          RHINE_METROPOLIS_HEXES.each do |hex_name|
            metropolis_visits = yellow_rhine_metropolis_visits.select { |name, _| name == hex_name }
            next unless metropolis_visits.size > 1

            west, east = metropolis_visits.partition { |_, is_west| is_west }
            found = ['West', "#{metropolis_name(hex_name, true)} (#{hex_name})"] if west.size > 1
            found = ['East', "#{metropolis_name(hex_name, false)} (#{hex_name})"] if east.size > 1
          end
          found
        end

        def visit_on_west_side?(visit)
          # To figure out if the city is on the West or East side on the Rhine Metropolis
          # yellow hex, use the index of the cities on the tile. Index 0 is always West,
          # and index 2 always East. Index 1 is West on Cologne hex, and East on the other two.

          case visit.hex.tile.cities.index(visit)
          when 0
            true
          when 2
            false
          else
            visit.hex.name == 'I10'
          end
        end

        def get_location_name(hex_name)
          @hexes.find { |h| h.name == hex_name }.location_name
        end

        def metropolis_name(metropolis_hex_name, is_west)
          west_name, east_name = get_location_name(metropolis_hex_name).split
          is_west || !east_name ? west_name : east_name
        end

        def off_board_out_tokened_penalty(route, stops, corporation)
          bonus = { revenue: 0 }

          stops.each do |s|
            next unless out_tokened_hex?(s.hex, corporation)

            bonus[:revenue] -= s.route_revenue(route.phase, route.train)
            block = "#{s.hex.name} tokened"
            bonus[:description] = (bonus[:description] ? "#{bonus[:description]}, #{block}" : block)
          end
          bonus
        end

        def out_tokened_hex?(hex, corporation)
          return false unless OUT_TOKENED_HEXES.include?(hex.name)

          tile_cities = hex.tile.cities
          return false if tile_cities.empty? || tile_cities.first.tokens.empty?

          tile_cities.first.tokens.find { |t| t&.corporation != corporation }
        end

        def montan_bonus(route, stops)
          bonus = { revenue: 0 }
          return bonus if route.train.name == '8'

          coal = count_coal(route, stops)
          return bonus if coal.zero?

          steel = count_steel(route, stops)
          return bonus if steel.zero?

          if coal > 1 && steel > 1
            bonus[:revenue] = brown_phase? ? 80 : 40
            bonus[:description] = 'Double Montan'
          else
            bonus[:revenue] = brown_phase? ? 40 : 20
            bonus[:description] = 'Montan'
          end
          bonus
        end

        def count_coal(route, stops)
          coal = visited_icons(stops, 'K')
          coal += 1 if stops.find { |s| EASTERN_RUHR_HEXES.include?(s.hex.id) && coal_edge_used?(route, s.hex.id) }
          coal
        end

        def count_steel(route, stops)
          steel = visited_icons(stops, 'S')
          steel += 1 if stops.find { |s| EASTERN_RUHR_HEXES.include?(s.hex.id) && steel_edge_used?(route, s.hex.id) }
          steel += 1 if stops.find { |s| s.hex.id == 'J15' }
          steel
        end

        def eastern_ruhr_area_bonus(stops)
          bonus = { revenue: 0 }
          return bonus if stops.none? { |s| EASTERN_RUHR_HEXES.include?(s.hex.id) }

          links = @eastern_ruhr_connections.size
          bonus[:revenue] = 10 * links
          bonus[:description] = "#{links} link#{links > 1 ? 's' : ''}"
          bonus
        end

        def iron_rhine_bonus(stops, corporation)
          bonus = { revenue: 0 }
          return bonus if out_tokened_hex?(roermund_hex, corporation) ||
                          stops.none? { |s| s.hex.id == roermund_hex.id } ||
                          stops.none? { |s| eastern_ruhr.include?(s.hex.id) }

          bonus[:revenue] = 80
          bonus[:description] = 'Iron Rhine'
          bonus
        end

        def trajekt_usage_penalty(route, _stops)
          # For any green Rhine Metropolis hex, we need to find out if the route
          # passes from East to West (or reverse), as that means the ferry
          # (the trajekt) has been used. By using the route information, and
          # check for which edges are used, we can figure out if such an East-West
          # or West-East passge has occured in these hexes.

          bonus = { revenue: 0 }
          trajekts_used = 0

          hexes_with_edge_visited = get_hexes_with_edge_visited(route)
          [duisburg_hex, dusseldorf_hex, cologne_hex].each do |metropolis_hex|
            next unless metropolis_hex.tile.color == :green

            used_city = hexes_with_edge_visited.select { |h, _| h == metropolis_hex.name }
            next unless used_city.size > 1

            west, east = used_city.partition { |_, edge| edge < 3 }
            next if west.empty? || east.empty?

            trajekts = west.size
            trajekts = east.size if east.size < west.size
            trajekts_used += trajekts
          end

          return bonus unless trajekts_used.positive?

          bonus[:revenue] = -10 * trajekts_used
          bonus[:description] = "#{trajekts_used} trajekt#{trajekts_used > 1 ? 's' : ''}"
          bonus
        end

        def get_hexes_with_edge_visited(route)
          # Get a list of all uniq exists where each element is in the form [hex name, edge number]

          route.chains.flat_map { |c| c[:paths] }.flat_map { |p| [p.hex.name].product(p.exits) }.uniq
        end

        def rheingold_express_bonus(route, stops)
          bonus = { revenue: 0 }
          return bonus unless route.train.name == '8'

          # Double any Rhine Metropolis cities visited
          stops.each do |s|
            next unless RHINE_METROPOLIS_HEXES.include?(s.hex.name)

            bonus[:revenue] += s.route_revenue(route.phase, route.train)
          end

          bonus[:description] = 'RGE'
          bonus
        end

        def ratingen_bonus(route, stops)
          bonus = { revenue: 0 }
          return bonus if !optional_ratingen_variant ||
                          route.train.name == '8' ||
                          stops.none? { |s| s.hex.id == RATINGEN_HEX } ||
                          count_steel(route, stops).zero?

          bonus[:revenue] = 30
          bonus[:description] = 'Ratingen'
          bonus
        end

        def check_connections(corp, destination)
          duren_node = duren_hex.tile.cities.first # Each tile with a city has exactly one node

          destination.tile.nodes.first&.walk(corporation: corp) do |path, _, _|
            return true if path.nodes.include?(duren_node)
          end

          false
        end

        def visited_icons(stops, icon_name)
          stops.select { |s| s.hex.tile.icons.any? { |i| i.name == icon_name } }
               .map { |s| s.hex.name }
               .uniq
               .size
        end

        def trajekts_used?(hex_name, route)
          route.chains.any? { |c| western_edge_used?(hex_name, c) && eastern_edge_used?(hex_name, c) }
        end

        def western_edge_used?(hex_name, chain)
          edge_used?(chain, hex_name, [0, 1, 2])
        end

        def eastern_edge_used?(hex_name, chain)
          edge_used?(chain, hex_name, [3, 4, 5])
        end

        def coal_edge_used?(route, hex_name)
          edge_of_interest = hex_name == 'C14' ? 1 : 0
          route.chains.any? { |c| edge_used?(c, hex_name, [edge_of_interest]) }
        end

        def steel_edge_used?(route, hex_name)
          edge_of_interest = hex_name == 'C14' ? 0 : 1
          route.chains.any? { |c| edge_used?(c, hex_name, [edge_of_interest]) }
        end

        def edge_used?(chain, hex_name, edges_of_interest)
          chain[:paths].any? { |p| p.hex.name == hex_name && !(p.exits & edges_of_interest).empty? }
        end

        def tile_has_specified_exits?(hex, specified_exits)
          !(hex.tile.exits & specified_exits).empty?
        end

        def remove_trajekt_icon(tile)
          tile.icons.reject! { |i| i.name == 'trajekt' }
        end
      end
    end
  end
end
