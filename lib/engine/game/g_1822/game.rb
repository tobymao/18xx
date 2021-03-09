# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative '../stubs_are_restricted'

module Engine
  module Game
    module G1822
      class Game < Game::Base
        include_meta(G1822::Meta)

        register_colors(lnwrBlack: '#000',
                        gwrGreen: '#165016',
                        lbscrYellow: '#cccc00',
                        secrOrange: '#ff7f2a',
                        crBlue: '#5555ff',
                        mrRed: '#ff2a2a',
                        lyrPurple: '#5a2ca0',
                        nbrBrown: '#a05a2c',
                        swrGray: '#999999',
                        nerGreen: '#aade87',
                        black: '#000',
                        white: '#ffffff')

        GAME_END_CHECK = { bank: :full_or, stock_market: :current_or }.freeze

        BANKRUPTCY_ALLOWED = false

        CURRENCY_FORMAT_STR = '£%d'

        BANK_CASH = 12_000

        CERT_LIMIT = { 3 => 26, 4 => 20, 5 => 16, 6 => 13, 7 => 11 }.freeze

        STARTING_CASH = { 3 => 700, 4 => 525, 5 => 420, 6 => 350, 7 => 300 }.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false

        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 6,
          '4' => 6,
          '5' => 6,
          '6' => 8,
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '55' => 1,
          '56' => 1,
          '57' => 6,
          '58' => 6,
          '69' => 1,
          '14' => 6,
          '15' => 6,
          '80' => 6,
          '81' => 6,
          '82' => 8,
          '83' => 8,
          '141' => 4,
          '142' => 4,
          '143' => 4,
          '144' => 4,
          '207' => 2,
          '208' => 1,
          '619' => 6,
          '622' => 1,
          '63' => 8,
          '544' => 6,
          '545' => 6,
          '546' => 8,
          '611' => 4,
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
              'count' => 3,
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
          '145' =>
            {
              'count' => 4,
              'color' => 'brown',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            },
          '146' =>
            {
              'count' => 4,
              'color' => 'brown',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            },
          '147' =>
            {
              'count' => 6,
              'color' => 'brown',
              'code' =>
                'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
          'X5' =>
            {
              'count' => 3,
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
                'city=revenue:50,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=C',
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
              'count' => 3,
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
                'city=revenue:60,slots:2;path=a:1,b:_0;path=a:4,b:_0;label=S',
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

        LOCATION_NAMES = {
          'A42' => 'Cornwall',
          'B43' => 'Plymouth',
          'C34' => 'Fishguard',
          'C38' => 'Barnstaple',
          'D11' => 'Stranraer',
          'D35' => 'Swansea & Oystermouth',
          'D41' => 'Exeter',
          'E2' => 'Highlands',
          'E6' => 'Glasgow',
          'E28' => 'Mid Wales',
          'E32' => 'Merthyr Tydfil & Pontypool',
          'E40' => 'Taunton',
          'F3' => 'Stirling',
          'F5' => 'Castlecary',
          'F7' => 'Hamilton & Coatbridge',
          'F11' => 'Dumfries',
          'F23' => 'Holyhead',
          'F35' => 'Cardiff',
          'G4' => 'Falkirk',
          'G12' => 'Carlisle',
          'G16' => 'Barrow',
          'G20' => 'Blackpool',
          'G22' => 'Liverpool',
          'G24' => 'Chester',
          'G28' => 'Shrewbury',
          'G32' => 'Hereford',
          'G34' => 'Newport',
          'G36' => 'Bristol',
          'G42' => 'Dorchester',
          'H1' => 'Aberdeen',
          'H3' => 'Dunfermline',
          'H5' => 'Edinburgh',
          'H13' => 'Penrith',
          'H17' => 'Lancaster',
          'H19' => 'Preston',
          'H21' => 'Wigan & Bolton',
          'H23' => 'Warrington',
          'H25' => 'Crewe',
          'H33' => 'Gloucester',
          'H37' => 'Bath & Radstock',
          'I22' => 'Manchester',
          'I26' => 'Stoke-on-Trent',
          'I30' => 'Birmingham',
          'I40' => 'Salisbury',
          'I42' => 'Bournemouth',
          'J15' => 'Darlington',
          'J21' => 'Bradford',
          'J29' => 'Derby',
          'J31' => 'Coventry',
          'J41' => 'Southampton',
          'K10' => 'Newcastle',
          'K12' => 'Durham',
          'K14' => 'Middlesbrough',
          'K20' => 'Leeds',
          'K24' => 'Sheffield',
          'K28' => 'Nottingham',
          'K30' => 'Leicester',
          'K36' => 'Oxford',
          'K38' => 'Reading',
          'K42' => 'Portsmouth',
          'L19' => 'York',
          'L33' => 'Northampton',
          'M16' => 'Scarborough',
          'M26' => 'Lincoln',
          'M30' => 'Peterborough',
          'M36' => 'Hertford',
          'M38' => 'London',
          'M42' => 'Brighton',
          'N21' => 'Hull',
          'N23' => 'Grimsby',
          'N33' => 'Cambridge',
          'O30' => "King's Lynn",
          'O36' => 'Colchester',
          'O40' => 'Maidstone',
          'O42' => 'Folkstone',
          'P35' => 'Ipswich',
          'P39' => 'Canterbury',
          'P41' => 'Dover',
          'P43' => 'English Channel',
          'Q44' => 'France',
        }.freeze

        MARKET = [
          ['', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '550', '600', '650', '700e'],
          ['', '', '', '', '', '', '', '', '', '', '', '', '', '330', '360', '400', '450', '500', '550', '600', '650'],
          ['', '', '', '', '', '', '', '', '', '200', '220', '245', '270', '300', '330', '360', '400', '450', '500',
           '550', '600'],
          %w[70 80 90 100 110 120 135 150 165 180 200 220 245 270 300 330 360 400 450 500 550],
          %w[60 70 80 90 100px 110 120 135 150 165 180 200 220 245 270 300 330 360 400 450 500],
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

        PHASES = [
          {
            name: '1',
            on: '',
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '2',
            on: %w[2 3],
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            status: ['can_convert_concessions'],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '3',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            status: %w[can_buy_trains can_convert_concessions],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: { minor: 1, major: 3 },
            tiles: %i[yellow green],
            status: %w[can_buy_trains can_convert_concessions],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            status: %w[can_buy_trains
                       can_acquire_minor_bidbox
                       can_par
                       minors_green_upgrade],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            status: %w[can_buy_trains
                       can_acquire_minor_bidbox
                       can_par
                       full_capitalisation
                       minors_green_upgrade],
            operating_rounds: 2,
          },
          {
            name: '7',
            on: '7',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown gray],
            status: %w[can_buy_trains
                       can_acquire_minor_bidbox
                       can_par
                       full_capitalisation
                       minors_green_upgrade],
            operating_rounds: 2,
          },
        ].freeze

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
            num: 22,
            price: 60,
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
            num: 9,
            price: 200,
            rusts_on: '6',
          },
          {
            name: '4',
            distance: 4,
            num: 6,
            price: 300,
            rusts_on: '7',
          },
          {
            name: '5',
            distance: 5,
            num: 3,
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
            price: 0,
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

        COMPANIES = [
          {
            name: 'P1-BEC',
            sym: 'P1',
            value: 0,
            revenue: 5,
            desc: 'MAJOR, Phase 5. 5-Train. This is a normal 5-train that is subject to all of the normal rules. '\
                  'Note that a company can acquire this private company at the start of its turn, even if it is '\
                  'already at its train limit as this counts as an acquisition action, not a train buying action. '\
                  'However, once acquired the acquiring company needs to check whether it is at train limit and '\
                  'discard any trains held in excess of limit.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P2-MtonR',
            sym: 'P2',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 2. Remove Small Station. Allows the owning company to place a plain yellow '\
                  'track tile directly on an undeveloped small station hex location or upgrade a small station tile '\
                  'of one colour to a plain track tile of the next colour. This closes the company and counts as '\
                  'the company’s normal track laying step. All other normal track laying restrictions apply. Once '\
                  'acquired, the private company pays its revenue to the owning company until the power is '\
                  'exercised and the company is closed.',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                when: 'track',
                count: 1,
                reachable: true,
                closed_when_used_up: true,
                hexes: [],
                tiles: %w[7 8 9 80 81 82 83 544 545 546 60 169],
              },
            ],
            color: nil,
          },
          {
            name: 'P3-S&HR',
            sym: 'P3',
            value: 0,
            revenue: 0,
            desc: 'MAJOR, Phase 2. Permanent 2-Train. 2P-train is a permanent 2-train. It can’t be sold to another '\
                  'company. It does not count against train limit. It does not count as a train for the purpose of '\
                  'mandatory train ownership and purchase. A company may not own more than one 2P train. Dividends '\
                  'can be separated from other trains and may be split, paid in full, or retained. If a company '\
                  'runs a 2P-train and pays a dividend (split or full), but retains its dividend from other train '\
                  'operations this still counts as a normal dividend for stock price movement purposes. Vice-versa, '\
                  'if a company pays a dividend (split or full) with its other trains, but retains the dividend '\
                  'from the 2P, this also still counts as a normal dividend for stock price movement purposes. Does '\
                  'not close.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P4-SDR',
            sym: 'P4',
            value: 0,
            revenue: 0,
            desc: 'MAJOR, Phase 2. Permanent 2-Train. 2P-train is a permanent 2-train. It can’t be sold to another '\
                  'company. It does not count against train limit. It does not count as a train for the purpose of '\
                  'mandatory train ownership and purchase. A company may not own more than one 2P train. Dividends '\
                  'can be separated from other trains and may be split, paid in full, or retained. If a company '\
                  'runs a 2P-train and pays a dividend (split or full), but retains its dividend from other train '\
                  'operations this still counts as a normal dividend for stock price movement purposes. Vice-versa, '\
                  'if a company pays a dividend (split or full) with its other trains, but retains the dividend '\
                  'from the 2P, this also still counts as a normal dividend for stock price movement purposes. '\
                  'Does not close.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P5-LC&DR',
            sym: 'P5',
            value: 0,
            revenue: 10,
            desc: 'MAJOR, Phase 3. English Channel. The owning company may place an exchange station token on the '\
                  'map, free of charge, in a token space in the English Channel. The company does not need to be '\
                  'able to trace a route to the English Channel to use this property (i.e. any company can use this '\
                  'power to place a token in the English Channel). If no token spaces are available, but a space '\
                  'could be created by upgrading the English Channel track then this power may be used to place a '\
                  'token and upgrade the track simultaneously. This counts as the acquiring company’s tile lay '\
                  'action and incurs the usual costs for doing so. Alternatively, it can move an exchange station '\
                  'token to the available station token section on its company charter.',
            abilities: [
              {
                type: 'teleport',
                owner_type: 'corporation',
                hexes: ['P43'],
                tiles: %w[X9 X15],
              },
              {
                type: 'token',
                owner_type: 'corporation',
                hexes: ['P43'],
                price: 0,
                teleport_price: 0,
                count: 1,
                extra: true,
              },
            ],
            color: nil,
          },
          {
            name: 'P6-L&SR',
            sym: 'P6',
            value: 0,
            revenue: 10,
            desc: 'MAJOR, Phase 3. Mail Contract. After running trains, the owning company receives income into its '\
                  'treasury equal to one half of the base value of the start and end stations from one of the '\
                  'trains operated. Doubled values (for E trains or destination tokens) do not count. The company '\
                  'is not required to maximise the dividend from its run if it wishes to maximise its revenue from '\
                  'the mail contract by stopping at a large city and not running beyond it to include small '\
                  'stations. Does not close.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P7-S&BR',
            sym: 'P7',
            value: 0,
            revenue: 10,
            desc: 'MAJOR, Phase 3. Mail Contract. After running trains, the owning company receives income into its '\
                  'treasury equal to one half of the base value of the start and end stations from one of the '\
                  'trains operated. Doubled values (for E trains or destination tokens) do not count. The company '\
                  'is not required to maximise the dividend from its run if it wishes to maximise its revenue from '\
                  'the mail contract by stopping at a large city and not running beyond it to include small '\
                  'stations. Does not close.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P8-E&GR',
            sym: 'P8',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 3. Mountain/Hill Discount. Either: The acquiring company receives a discount '\
                  'token that can be used to pay the full cost of a single track tile lay on a rough terrain, hill '\
                  'or mountain hex. This closes the company. Or: The acquiring company rejects the token and '\
                  'receives a £20 discount off the cost of all hill and mountain terrain (i.e. NOT off the cost of '\
                  'rough terrain). The private company does not close. Closes if free token taken when acquired. '\
                  'Otherwise, flips when acquired and does not close.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P9-M&GNR',
            sym: 'P9',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 3. Declare 2x Cash Holding. If held by a player, the holding player may '\
                  'declare double their actual cash holding at the end of a stock round to determine player turn '\
                  'order in the next stock round. If held by a company it pays revenue of '\
                  '£20 (green)/£40 (brown)/£60 (grey). Does not close.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P10-G&SWR',
            sym: 'P10',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 3. River/Estuary Discount. The acquiring company receives two discount tokens '\
                  'each of which can be used to pay the cost for one track lay over an estuary crossing. They can '\
                  'be used on the same or different tile lays. Use of the second token closes the company. In '\
                  'addition, until the company closes it provides a discount of £10 against the cost of all river '\
                  'terrain (excluding estuary crossings).',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                when: 'track',
                count: 2,
                reachable: true,
                closed_when_used_up: true,
                hexes: [],
                tiles: [],
              },
              {
                type: 'tile_discount',
                owner_type: 'corporation',
                discount: 10,
                terrain: 'swamp',
              },
            ],
            color: nil,
          },
          {
            name: 'P11-B&ER',
            sym: 'P11',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 2. Advanced Tile Lay. The owning company may lay one plain or small station '\
                  'track upgrade using the next colour of track to be available, before it is actually made '\
                  'available by phase progression. The normal rules for progression of track lay must be followed '\
                  '(i.e. grey upgrades brown upgrades green upgrades yellow) it is not possible to skip a colour '\
                  'using this private. All other normal track laying restrictions apply. This is in place of its '\
                  'normal track lay action. Once acquired, the private company pays its revenue to the owning '\
                  'company until the power is exercised and the company closes.',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                when: 'track',
                count: 1,
                reachable: true,
                closed_when_used_up: true,
                hexes: [],
                tiles: %w[80 81 82 83 544 545 546 60 169 141 142 143 144 145 146 147 X17],
              },
            ],
            color: nil,
          },
          {
            name: 'P12-L&SR',
            sym: 'P12',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 3. Extra Tile Lay. The owning company may lay an additional yellow tile (or '\
                  'two for major companies), or make one additional tile upgrade in its track laying step. The '\
                  'upgrade can be to a tile laid in its normal tile laying step. All other normal track laying '\
                  'restrictions apply. Once acquired, the private company pays its revenue to the owning company '\
                  'until the power is exercised and the company closes.',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                when: 'track',
                count: 2,
                reachable: true,
                closed_when_used_up: true,
                hexes: [],
                tiles: [],
              },
            ],
            color: nil,
          },
          {
            name: 'P13-YN&BR',
            sym: 'P13',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 5. Pullman. A “Pullman” carriage train that can be added to another train '\
                  'owned by the company. It converts the train into a + train. Does not count against train limit '\
                  'and does not count as a train for the purposes of train ownership. Can’t be sold to another '\
                  'company. Does not close.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P14-K&TR',
            sym: 'P14',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 5. Pullman. A “Pullman” carriage train that can be added to another train '\
                  'owned by the company. It converts the train into a + train. Does not count against train limit '\
                  'and does not count as a train for the purposes of train ownership. Can’t be sold to another '\
                  'company. Does not close.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P15-HR',
            sym: 'P15',
            value: 0,
            revenue: 0,
            desc: 'MAJOR/MINOR, Phase 2. £10x Phase. Pays revenue of £10 x phase number to the player, and pays '\
                  'treasury credits of £10 x phase number to the private company. This credit is retained on the '\
                  'private company charter. When acquired, the acquiring company receives this treasury money and '\
                  'this private company closes. If not acquired beforehand, this company closes at the start of '\
                  'Phase 7 and all treasury credits are returned to the bank.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P16-TH',
            sym: 'P16',
            value: 0,
            revenue: 0,
            desc: 'CAN NOT BE AQUIRED. Tax Haven. As a stock round action, under the direction and funded by the '\
                  'owning player, the off-shore Tax Haven may purchase an available share certificate and place it '\
                  'onto P16’s charter. The certificate is not counted for determining directorship of a company. '\
                  'The share held in the tax haven does NOT count against the 60% share limit for purchasing '\
                  'shares. If at 60% (or more) in hand in a company, a player can still purchase an additional '\
                  'share in that company and place it in the tax haven. Similarly, if a player holds 50% of a '\
                  'company, plus has 10% of the same company in the tax haven, they can buy a further 10% share. '\
                  'A company with a share in the off-shore tax haven CAN be “all sold out” at the end of a stock '\
                  'round. Dividends paid to the share are also placed onto the off-shore tax haven charter. At the '\
                  'end of the game, the player receives the share certificate from the off-shore tax haven charter '\
                  'and includes it in their portfolio for determining final worth. The player also receives the '\
                  'cash from dividend income accumulated on the charter. Can’t be acquired. Does not count against '\
                  'the certificate limit.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P17-LUR',
            sym: 'P17',
            value: 0,
            revenue: 10,
            desc: 'MAJOR, Phase 2. Move Card. Allows the director of the owning company to select one concession, '\
                  'private company, or minor company from the relevant stack of certificates, excluding those items '\
                  'currently in the bidding boxes, and move it to the top or the bottom of the stack. Closes when '\
                  'the power is exercised.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P18-C&HPR',
            sym: 'P18',
            value: 0,
            revenue: 10,
            desc: 'MAJOR, Phase 5. Station Marker Swap. Allows the owning company to move a token from the exchange '\
                  'token area of its charter to the available token area, or vice versa. This company closes when '\
                  'its power is exercised.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P19-AEC',
            sym: 'P19',
            value: 0,
            revenue: 0,
            desc: 'MAJOR/MINOR, Phase 1. Permanent L-Train. An L-train cannot be sold to another company. It does '\
                  'not count as a train for the purposes of mandatory train ownership. It does not count against '\
                  'train ownership limit A company cannot own a permanent L-train and a permanent 2-train. '\
                  'Dividends can be separated from other trains and may be split, paid in full, or retained. If a '\
                  'company runs a permanent L-train and pays a dividend (split or full), but retains its dividend '\
                  'from other train operations this still counts as a normal dividend for stock price movement '\
                  'purposes. Vice-versa, if a company pays a dividend (split or full) with its other trains, but '\
                  'retains the dividend from the permanent L, this also still counts as a normal dividend for stock '\
                  'price movement purposes. Does not close.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P20-C&WR',
            sym: 'P20',
            value: 0,
            revenue: 0,
            desc: 'MAJOR/MINOR, Phase 3. £5x Phase. Pays revenue of £5 x phase number to the player, and pays '\
                  'treasury credits of £5 x phase number to the private company. This credit is retained on the '\
                  'private company charter. When acquired, the acquiring company receives this treasury money and '\
                  'this private company closes. If not acquired beforehand, this company closes at the start of '\
                  'Phase 7 and all treasury credits are returned to the bank.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P21-HSBC',
            sym: 'P21',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 2. Grimsby/Hull Bridge. Allows the owning company to lay yellow tiles in '\
                  'Grimsby and / or Hull, forming a direct track connection between the two cities over the '\
                  'Humber estuary. If one of the cities already has a yellow tile in place, then if used in phase 3 '\
                  'or later, one of the tile lays may be a green upgrade. No terrain costs apply for these tile '\
                  'lays. These tile lays count as the normal track laying phase for the operating company. The '\
                  'owning company must have a token in Hull or Grimsby to use this power. Closes when its power is '\
                  'exercised.',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                when: 'track',
                count: 2,
                free: true,
                reachable: true,
                closed_when_used_up: true,
                hexes: %w[N21 N23],
                tiles: %w[5 6 57 15],
              },
            ],
            color: nil,
          },
          {
            name: 'CONCESSION: LNWR',
            sym: 'C1',
            value: 100,
            revenue: 10,
            desc: 'Have a face value £100 and converts into the LNWR’s 10% director certificate. LNWR may also put '\
                  'it’s destination token into Manchester when converted.',
            abilities: [
              {
                type: 'exchange',
                corporations: ['LNWR'],
                owner_type: 'player',
                from: 'par',
              },
            ],
            color: '#000',
            text_color: 'white',
          },
          {
            name: 'CONCESSION: GWR',
            sym: 'C2',
            value: 100,
            revenue: 10,
            desc: 'Have a face value £100 and contribute £100 to the conversion into the GWR director’s certificate.',
            abilities: [
              {
                type: 'exchange',
                corporations: ['GWR'],
                owner_type: 'player',
                from: 'par',
              },
            ],
            color: '#165016',
            text_color: 'white',
          },
          {
            name: 'CONCESSION: LBSCR',
            sym: 'C3',
            value: 100,
            revenue: 10,
            desc: 'Have a face value £100 and contribute £100 to the conversion into the LBSCR director’s '\
                  'certificate.',
            abilities: [
              {
                type: 'exchange',
                corporations: ['LBSCR'],
                owner_type: 'player',
                from: 'par',
              },
            ],
            color: '#cccc00',
            text_color: 'white',
          },
          {
            name: 'CONCESSION: SECR',
            sym: 'C4',
            value: 100,
            revenue: 10,
            desc: 'Have a face value £100 and contribute £100 to the conversion into the SECR director’s '\
                  'certificate.',
            abilities: [
              {
                type: 'exchange',
                corporations: ['SECR'],
                owner_type: 'player',
                from: 'par',
              },
            ],
            color: '#ff7f2a',
            text_color: 'white',
          },
          {
            name: 'CONCESSION: CR',
            sym: 'C5',
            value: 100,
            revenue: 10,
            desc: 'Have a face value £100 and contribute £100 to the conversion into the CR director’s certificate.',
            abilities: [
              {
                type: 'exchange',
                corporations: ['CR'],
                owner_type: 'player',
                from: 'par',
              },
            ],
            color: '#5555ff',
            text_color: 'white',
          },
          {
            name: 'CONCESSION: MR',
            sym: 'C6',
            value: 100,
            revenue: 10,
            desc: 'Have a face value £100 and contribute £100 to the conversion into the MR director’s certificate.',
            abilities: [
              {
                type: 'exchange',
                corporations: ['MR'],
                owner_type: 'player',
                from: 'par',
              },
            ],
            color: '#ff2a2a',
            text_color: 'white',
          },
          {
            name: 'CONCESSION: LYR',
            sym: 'C7',
            value: 100,
            revenue: 10,
            desc: 'Have a face value £100 and contribute £100 to the conversion into the LYR director’s certificate.',
            abilities: [
              {
                type: 'exchange',
                corporations: ['LYR'],
                owner_type: 'player',
                from: 'par',
              },
            ],
            color: '#5a2ca0',
            text_color: 'white',
          },
          {
            name: 'CONCESSION: NBR',
            sym: 'C8',
            value: 100,
            revenue: 10,
            desc: 'Have a face value £100 and contribute £100 to the conversion into the NBR director’s certificate.',
            abilities: [
              {
                type: 'exchange',
                corporations: ['NBR'],
                owner_type: 'player',
                from: 'par',
              },
            ],
            color: '#a05a2c',
            text_color: 'white',
          },
          {
            name: 'CONCESSION: SWR',
            sym: 'C9',
            value: 100,
            revenue: 10,
            desc: 'Have a face value £100 and contribute £100 to the conversion into the SWR director’s certificate.',
            abilities: [
              {
                type: 'exchange',
                corporations: ['SWR'],
                owner_type: 'player',
                from: 'par',
              },
            ],
            color: '#999999',
            text_color: 'white',
          },
          {
            name: 'CONCESSION: NER',
            sym: 'C10',
            value: 100,
            revenue: 10,
            desc: 'Have a face value £100 and contribute £100 to the conversion into the NER director’s certificate.',
            abilities: [
              {
                type: 'exchange',
                corporations: ['NER'],
                owner_type: 'player',
                from: 'par',
              },
            ],
            color: '#aade87',
            text_color: 'white',
          },
          {
            name: 'MINOR: 1. Great North of Scotland Railway',
            sym: 'M1',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is H1.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 2. Lanarkshire & Dumbartonshire Railway',
            sym: 'M2',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is E2.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 3. Edinburgh & Dalkeith Railway',
            sym: 'M3',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is H5.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 4. Newcastle & North shields Railway',
            sym: 'M4',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is K10.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 5. Stockton and Darlington Railway',
            sym: 'M5',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is J15.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 6. Furness railway',
            sym: 'M6',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is G16.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 7. Warrington & Newton Railway',
            sym: 'M7',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is H23.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 8. Manchester Sheffield & Lincolnshire Railway',
            sym: 'M8',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is K24.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 9. East Lincolnshire Railway',
            sym: 'M9',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is N23.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 10. Grand Junction Railway',
            sym: 'M10',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is I30.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 11. Great Northern Railway',
            sym: 'M11',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is M30.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 12. Eastern Union Railway',
            sym: 'M12',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is P35.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 13. Headcorn & Maidstone Junction Light Railway',
            sym: 'M13',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is O40.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 14. Metropolitan Railway',
            sym: 'M14',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is M38.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 15. London Tilbury & Southend Railway',
            sym: 'M15',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is M38.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 16. Wycombe Railway',
            sym: 'M16',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is M38.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 17. London & Southampton Railway',
            sym: 'M17',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is J41.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 18. Somerset & Dorset Joint Railway',
            sym: 'M18',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is I42.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 19. Penarth Harbour & Dock Railway Company',
            sym: 'M19',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is F35.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 20. Monmouthshire Railway & Canal Company',
            sym: 'M20',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is F33.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 21. Taff Vale railway',
            sym: 'M21',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is E34.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 22. Exeter and Crediton Railway',
            sym: 'M22',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is D41.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 23. West Cornwall Railway',
            sym: 'M23',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is A42.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 24. The Swansea and Mumbles Railway',
            sym: 'M24',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is D35.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 25. Yarmouth & Norwich Railway',
            sym: 'M25',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is Q30.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 26. Hull and Selby Railway',
            sym: 'M26',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is N21.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 27. City of Glasgow Union Railway',
            sym: 'M27',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is E6.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 28. Maryport and Carlisle Railway',
            sym: 'M28',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is G12.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 29. Shropshire and Montgomeryshire Railway',
            sym: 'M29',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is E28.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 30. Plymouth and Dartmoor Railway',
            sym: 'M30',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is B43.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: '1',
            name: 'Great North of Scotland Railway',
            logo: '1822/1',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'H1',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '2',
            name: 'Lanarkshire & Dumbartonshire Railway',
            logo: '1822/2',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'E2',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '3',
            name: 'Edinburgh & Dalkeith Railway',
            logo: '1822/3',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'H5',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '4',
            name: 'Newcastle & North shields Railway',
            logo: '1822/4',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'K10',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '5',
            name: 'Stockton and Darlington Railway',
            logo: '1822/5',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'J15',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '6',
            name: 'Furness railway',
            logo: '1822/6',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'G16',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '7',
            name: 'Warrington & Newton Railway',
            logo: '1822/7',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'H23',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '8',
            name: 'Manchester Sheffield & Lincolnshire Railway',
            logo: '1822/8',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'K24',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '9',
            name: 'East Lincolnshire Railway',
            logo: '1822/9',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'N23',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '10',
            name: 'Grand Junction Railway',
            logo: '1822/10',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'I30',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '11',
            name: 'Great Northern Railway',
            logo: '1822/11',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'M30',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '12',
            name: 'Eastern Union Railway',
            logo: '1822/12',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'P35',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '13',
            name: 'Headcorn & Maidstone Junction Light Railway',
            logo: '1822/13',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'O40',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '14',
            name: 'Metropolitan Railway',
            logo: '1822/14',
            tokens: [20],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '15',
            name: 'London Tilbury & Southend Railway',
            logo: '1822/15',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'M38',
            city: 4,
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '16',
            name: 'Wycombe Railway',
            logo: '1822/16',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'M38',
            city: 2,
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '17',
            name: 'London & Southampton Railway',
            logo: '1822/17',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'J41',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '18',
            name: 'Somerset & Dorset Joint Railway',
            logo: '1822/18',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'I42',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '19',
            name: 'Penarth Harbour & Dock Railway Company',
            logo: '1822/19',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'F35',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '20',
            name: 'Monmouthshire Railway & Canal Company',
            logo: '1822/20',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'F33',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '21',
            name: 'Taff Vale railway',
            logo: '1822/21',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'E34',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '22',
            name: 'Exeter and Crediton Railway',
            logo: '1822/22',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'D41',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '23',
            name: 'West Cornwall Railway',
            logo: '1822/23',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'A42',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '24',
            name: 'The Swansea and Mumbles Railway',
            logo: '1822/24',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'D35',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '25',
            name: 'Yarmouth & Norwich Railway',
            logo: '1822/25',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'Q30',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '26',
            name: 'Hull and Selby Railway',
            logo: '1822/26',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'N21',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '27',
            name: 'City of Glasgow Union Railway',
            logo: '1822/27',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'E6',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '28',
            name: 'Maryport and Carlisle Railway',
            logo: '1822/28',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'G12',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '29',
            name: 'Shropshire and Montgomeryshire Railway',
            logo: '1822/29',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'E28',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '30',
            name: 'Shropshire and Montgomeryshire Railway',
            logo: '1822/30',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'B43',
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: 'LNWR',
            name: 'London and North West Railway',
            logo: '1822/LNWR',
            tokens: [0, 100],
            type: 'major',
            float_percent: 10,
            shares: [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
            always_market_price: true,
            coordinates: 'M38',
            city: 3,
            color: '#000',
            reservation_color: nil,
          },
          {
            sym: 'GWR',
            name: 'Great Western Railway',
            logo: '1822/GWR',
            tokens: [0, 100],
            type: 'major',
            float_percent: 20,
            always_market_price: true,
            coordinates: 'M38',
            city: 1,
            color: '#165016',
            reservation_color: nil,
          },
          {
            sym: 'LBSCR',
            name: 'London, Brighton and South Coast Railway',
            logo: '1822/LBSCR',
            tokens: [0, 100],
            type: 'major',
            float_percent: 20,
            always_market_price: true,
            coordinates: 'M38',
            city: 0,
            color: '#cccc00',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: 'SECR',
            name: 'South Eastern & Chatham Railway',
            logo: '1822/SECR',
            tokens: [0, 100],
            type: 'major',
            float_percent: 20,
            always_market_price: true,
            coordinates: 'M38',
            city: 5,
            abilities: [
              {
                type: 'token',
                description: 'Token in English Channel for free',
                hexes: ['P43'],
                count: 1,
                price: 0,
              },
            ],
            color: '#ff7f2a',
            reservation_color: nil,
          },
          {
            sym: 'CR',
            name: 'Caledonian Railway',
            logo: '1822/CR',
            tokens: [0, 100],
            type: 'major',
            float_percent: 20,
            always_market_price: true,
            coordinates: 'E6',
            color: '#5555ff',
            reservation_color: nil,
          },
          {
            sym: 'MR',
            name: 'Midland Railway',
            logo: '1822/MR',
            tokens: [0, 100],
            type: 'major',
            float_percent: 20,
            always_market_price: true,
            coordinates: 'J29',
            color: '#ff2a2a',
            reservation_color: nil,
          },
          {
            sym: 'LYR',
            name: 'Lancashire & Yorkshire Railway',
            logo: '1822/LYR',
            tokens: [0, 100],
            type: 'major',
            float_percent: 20,
            always_market_price: true,
            coordinates: 'G22',
            color: '#5a2ca0',
            reservation_color: nil,
          },
          {
            sym: 'NBR',
            name: 'North British Railway',
            logo: '1822/NBR',
            tokens: [0, 100],
            type: 'major',
            float_percent: 20,
            always_market_price: true,
            coordinates: 'H5',
            color: '#a05a2c',
            reservation_color: nil,
          },
          {
            sym: 'SWR',
            name: 'South Wales Railway',
            logo: '1822/SWR',
            tokens: [0, 100],
            type: 'major',
            float_percent: 20,
            always_market_price: true,
            coordinates: 'H33',
            color: '#999999',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: 'NER',
            name: 'North Eastern Railway',
            logo: '1822/NER',
            tokens: [0, 100],
            type: 'major',
            float_percent: 20,
            always_market_price: true,
            coordinates: 'L19',
            color: '#aade87',
            reservation_color: nil,
          },
        ].freeze

        HEXES = {
          white: {
            %w[B39 C10 D9 E8 E12 F41 G2 G6 G26 G38 G40 H11 H27 H29 H31 H41 I6 I28 I34 I36 J9 J11 J13 J17 J27 J33
               J35 J37 K8 K16 K18 K22 K26 K32 K34 K40 L15 L17 L23 L25 L27 L29 L31 L35 L41 M18 M20 M24 M32 M34 N19
               N25 N31 N35 N41 O32 O34 P27 P29 P31 P33 Q28 Q32 Q34] =>
              '',
            ['H43'] =>
              'border=edge:4,type:impassable',
            ['D37'] =>
              'border=edge:3,type:impassable;border=edge:4,type:impassable',
            ['N27'] =>
              'border=edge:0,type:impassable;border=edge:5,type:impassable',
            ['E36'] =>
              'border=edge:0,type:impassable;border=edge:1,type:impassable;border=edge:5,type:impassable',
            ['G10'] =>
              'border=edge:0,type:water,cost:40',
            ['O38'] =>
              'border=edge:2,type:water,cost:40;border=edge:3,type:water,cost:40;border=edge:5,type:impassable',
            ['N37'] =>
              'border=edge:0,type:water,cost:40;border=edge:5,type:water,cost:40;stub=edge:1',
            ['L37'] =>
              'stub=edge:5',
            ['L39'] =>
              'stub=edge:4',
            ['M40'] =>
              'stub=edge:3',
            %w[C42 F39 L21 M28] =>
              'upgrade=cost:20,terrain:swamp',
            ['O28'] =>
              'upgrade=cost:20,terrain:swamp;border=edge:1,type:impassable;border=edge:2,type:impassable',
            ['E38'] =>
              'upgrade=cost:20,terrain:swamp;border=edge:3,type:impassable',
            ['H35'] =>
              'upgrade=cost:20,terrain:swamp;border=edge:2,type:water,cost:40',
            ['N39'] =>
              'upgrade=cost:20,terrain:swamp;border=edge:3,type:water,cost:40;stub=edge:2',
            ['F37'] =>
              'upgrade=cost:20,terrain:swamp;border=edge:2,type:impassable;border=edge:3,type:impassable',
            %w[D43 I32 M22] =>
              'upgrade=cost:40,terrain:swamp',
            ['N29'] =>
              'upgrade=cost:40,terrain:swamp;border=edge:3,type:impassable;border=edge:4,type:impassable',
            %w[B41 D39 G14 G30 H39 I12 I24 I38 J39] =>
              'upgrade=cost:40,terrain:hill',
            %w[C40 E10 F9 G8 H7 H9 H15 I8 I10 J7 J23 J25] =>
              'upgrade=cost:60,terrain:hill',
            %w[I14 I16 I18 I20 J19] =>
              'upgrade=cost:80,terrain:mountain',
            %w[C38 D11 E40 F3 F5 G20 G28 G32 G42 H13 H25 I26 J31 K12 K36 M16 M26 N33 O42] =>
              'town=revenue:0',
            %w[H17 P39] =>
              'town=revenue:0;border=edge:2,type:impassable',
            ['H3'] =>
              'town=revenue:0;border=edge:1,type:impassable;border=edge:0,type:water,cost:40',
            ['F11'] =>
              'town=revenue:0;border=edge:5,type:impassable',
            ['O36'] =>
              'town=revenue:0;border=edge:0,type:water,cost:40',
            ['M36'] =>
              'town=revenue:0;stub=edge:0',
            %w[F7 H21] =>
              'town=revenue:0;town=revenue:0',
            ['H37'] =>
              'town=revenue:0;town=revenue:0;upgrade=cost:20,terrain:swamp',
            ['O30'] =>
              'town=revenue:0;upgrade=cost:20,terrain:swamp',
            ['G34'] =>
              'town=revenue:0;upgrade=cost:20,terrain:swamp;border=edge:0,type:water,cost:40;'\
              'border=edge:5,type:water,cost:40',
            ['G24'] =>
              'town=revenue:0;upgrade=cost:40,terrain:swamp',
            ['I40'] =>
              'town=revenue:0;upgrade=cost:40,terrain:hill',
            ['J21'] =>
              'town=revenue:0;upgrade=cost:60,terrain:hill',
            %w[D41 H19 J15 J29 J41 K10 K14 K20 K24 K28 K30 K38 L33 M30 P35 P41] =>
              'city=revenue:0',
            ['I42'] =>
              'city=revenue:0;border=edge:1,type:impassable',
            ['G4'] =>
              'city=revenue:0;border=edge:4,type:impassable',
            ['G16'] =>
              'city=revenue:0;border=edge:5,type:impassable',
            ['G12'] =>
              'city=revenue:0;border=edge:2,type:impassable;border=edge:3,type:water,cost:40',
            ['D35'] =>
              'city=revenue:20,loc:center;town=revenue:10,loc:1;path=a:_0,b:_1;border=edge:0,type:impassable;label=S',
            ['M38'] =>
              'city=revenue:20;city=revenue:20;city=revenue:20;city=revenue:20;city=revenue:20;city=revenue:20;'\
              'path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;upgrade=cost:20;'\
              'label=L',
            %w[B43 K42 M42] =>
              'city=revenue:0;label=T',
            %w[L19 Q30] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp',
            %w[H23 H33] =>
              'city=revenue:0;upgrade=cost:40,terrain:swamp',
            ['O40'] =>
              'city=revenue:0;upgrade=cost:40,terrain:hill',
            ['N21'] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;border=edge:0,type:water,cost:40',
            ['N23'] =>
              'city=revenue:0;upgrade=cost:20,terrain:swamp;border=edge:3,type:water,cost:40',
          },
          yellow: {
            ['F35'] =>
              'city=revenue:30,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;border=edge:0,type:impassable;'\
              'border=edge:5,type:impassable;label=C',
            ['G22'] =>
              'city=revenue:30,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=Y',
            ['G36'] =>
              'city=revenue:30,slots:2;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;border=edge:2,type:impassable;'\
              'border=edge:3,type:water,cost:40;upgrade=cost:20,terrain:swamp;label=Y',
            ['H5'] =>
              'city=revenue:30,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;border=edge:3,type:water,cost:40;'\
              'label=Y',
            ['I22'] =>
              'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;upgrade=cost:60,terrain:hill;'\
              'label=BM',
            ['I30'] =>
              'city=revenue:40,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;upgrade=cost:40,terrain:swamp;'\
              'label=BM',
            ['P43'] =>
              'city=revenue:0;upgrade=cost:100;label=EC',
          },
          gray: {
            ['A42'] =>
              'city=revenue:yellow_40|green_30|brown_30|gray_40,slots:2,loc:1.5;path=a:4,b:_0,terminal:1;'\
              'path=a:5,b:_0,terminal:1',
            ['C34'] =>
              'city=revenue:yellow_10|green_20|brown_30|gray_40,slots:2;path=a:5,b:_0,terminal:1',
            ['E2'] =>
              'city=revenue:yellow_10|green_10|brown_20|gray_20,slots:2;path=a:0,b:_0,terminal:1;'\
              'path=a:5,b:_0,terminal:1',
            ['E4'] =>
              'path=a:0,b:3',
            ['E6'] =>
              'city=revenue:yellow_40|green_50|brown_60|gray_70,slots:3,loc:1;path=a:0,b:_0;path=a:3,b:_0;'\
              'path=a:4,b:_0;path=a:5,b:_0',
            ['E26'] =>
              'path=a:0,b:4,lanes:2',
            ['E28'] =>
              'city=revenue:yellow_10|green_20|brown_20|gray_30,slots:3,loc:1.5;path=a:0,b:_0,lanes:2,terminal:1;'\
              'path=a:3,b:_0,lanes:2,terminal:1;path=a:4,b:_0,lanes:2,terminal:1;path=a:5,b:_0,lanes:2,terminal:1',
            ['E30'] =>
              'path=a:3,b:5,lanes:2',
            ['E32'] =>
              'path=a:0,b:5',
            ['E34'] =>
              'city=revenue:yellow_30|green_40|brown_30|gray_10,slots:2,loc:0;path=a:3,b:_0;'\
              'path=a:4,b:_0,terminal:1;path=a:5,b:_0',
            ['F23'] =>
              'city=revenue:yellow_20|green_20|brown_30|gray_40,slots:2;path=a:5,b:_0,terminal:1',
            %w[F25 F27] =>
              'path=a:1,b:4,a_lane:2.0;path=a:1,b:5,a_lane:2.1',
            %w[F29 F31] =>
              'path=a:2,b:4,a_lane:2.0;path=a:2,b:5,a_lane:2.1',
            ['F33'] =>
              'city=revenue:yellow_20|green_40|brown_30|gray_10,slots:2,loc:4;path=a:1,b:_0;path=a:2,b:_0,terminal:1;'\
              'path=a:5,b:_0',
            ['H1'] =>
              'city=revenue:yellow_30|green_40|brown_50|gray_60,slots:2;path=a:0,b:_0,terminal:1;'\
              'path=a:1,b:_0,terminal:1',
            ['Q44'] =>
              'offboard=revenue:yellow_0|green_60|brown_90|gray_120,visit_cost:0;path=a:2,b:_0',
          },
          blue: {
            %w[L11 J43 Q36 Q42 R31] =>
              'junction;path=a:2,b:_0,terminal:1',
            ['F17'] =>
              'junction;path=a:4,b:_0,terminal:1',
            %w[F15 F21] =>
              'junction;path=a:5,b:_0,terminal:1',
          },
        }.freeze

        LAYOUT = :flat

        SELL_MOVEMENT = :down_share

        HOME_TOKEN_TIMING = :operate
        MUST_BID_INCREMENT_MULTIPLE = true
        MUST_BUY_TRAIN = :always
        NEXT_SR_PLAYER_ORDER = :most_cash

        SELL_AFTER = :operate

        SELL_BUY_ORDER = :sell_buy

        EVENTS_TEXT = {
          'close_concessions' =>
            ['Concessions close', 'All concessions close without compensation, major companies now float at 50%'],
          'full_capitalisation' =>
            ['Full capitalisation', 'Major companies now receives full capitalisation when floated'],
          'phase_revenue' =>
            ['Phase revenue', 'Highland Railway and Canterbury & Whitstable Railway closes if not acquired by a '\
                              'major company'],
        }.freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'can_buy_trains' => ['Buy trains', 'Can buy trains from other corporations'],
          'can_convert_concessions' => ['Convert concessions',
                                        'Can float a major company by converting a concession'],
          'can_acquire_minor_bidbox' => ['Acquire a minor from bidbox',
                                         'Can acquire a minor from bidbox for £200, must have connection '\
                                         'to start location'],
          'can_par' => ['Majors 50% float', 'Majors companies require 50% sold to float'],
          'full_capitalisation' => ['Full capitalisation', 'Majors receives full capitalisation '\
                                    '(the remaining five shares are placed in the bank)'],
        ).freeze

        BIDDING_BOX_MINOR_COUNT = 4
        BIDDING_BOX_CONCESSION_COUNT = 3
        BIDDING_BOX_PRIVATE_COUNT = 3

        BIDDING_BOX_START_MINOR = 'M24'
        BIDDING_BOX_START_CONCESSION = 'C1'
        BIDDING_BOX_START_PRIVATE = 'P1'

        BIDDING_TOKENS = {
          '3': 6,
          '4': 5,
          '5': 4,
          '6': 3,
          '7': 3,
        }.freeze

        BIDDING_TOKENS_PER_ACTION = 3

        COMPANY_CONCESSION_PREFIX = 'C'
        COMPANY_MINOR_PREFIX = 'M'
        COMPANY_PRIVATE_PREFIX = 'P'

        DESTINATIONS = {
          'LNWR' => 'I22',
          'GWR' => 'G36',
          'LBSCR' => 'M42',
          'SECR' => 'P41',
          'CR' => 'G12',
          'MR' => 'L19',
          'LYR' => 'I22',
          'NBR' => 'H1',
          'SWR' => 'C34',
          'NER' => 'H5',
        }.freeze

        EXCHANGE_TOKENS = {
          'LNWR' => 4,
          'GWR' => 3,
          'LBSCR' => 3,
          'SECR' => 3,
          'CR' => 3,
          'MR' => 3,
          'LYR' => 3,
          'NBR' => 3,
          'SWR' => 3,
          'NER' => 3,
        }.freeze

        # These trains don't count against train limit, they also don't count as a train
        # against the mandatory train ownership. They cant the bought by another corporation.
        EXTRA_TRAINS = %w[2P P+ LP].freeze
        EXTRA_TRAIN_PULLMAN = 'P+'
        EXTRA_TRAIN_PERMANENTS = %w[2P LP].freeze
        LOCAL_TRAINS = %w[L LP].freeze

        LIMIT_TOKENS_AFTER_MERGER = 9

        DOUBLE_HEX = %w[D35 F7 H21 H37].freeze
        CARDIFF_HEX = 'F35'
        LONDON_HEX = 'M38'
        ENGLISH_CHANNEL_HEX = 'P43'
        FRANCE_HEX = 'Q44'
        FRANCE_HEX_BROWN_TILE = 'offboard=revenue:yellow_0|green_60|brown_90|gray_120,visit_cost:0;'\
                                'path=a:2,b:_0,lanes:2'

        COMPANY_MTONR = 'P2'
        COMPANY_LCDR = 'P5'
        COMPANY_EGR = 'P8'
        COMPANY_MGNR = 'P9'
        COMPANY_MGNR_REVENUE = [0, 0, 0, 20, 20, 40, 40, 60].freeze
        COMPANY_GSWR = 'P10'
        COMPANY_GSWR_DISCOUNT = 40
        COMPANY_BER = 'P11'
        COMPANY_LSR = 'P12'
        COMPANY_HR = 'P15'
        COMPANY_OSTH = 'P16'
        COMPANY_LUR = 'P17'
        COMPANY_CHPR = 'P18'
        COMPANY_CWR = 'P20'
        COMPANY_HSBC = 'P21'
        COMPANY_HSBC_TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: true, upgrade: :not_if_upgraded, cannot_reuse_same_hex: true },
        ].freeze
        COMPANY_HSBC_TILES = %w[N21 N23].freeze

        COMPANY_SHORT_NAMES = {
          'P1' => 'P1-BEC',
          'P2' => 'P2-MtonR',
          'P3' => 'P3-S&HR',
          'P4' => 'P4-SDR',
          'P5' => 'P5-LC&DR',
          'P6' => 'P6-L&SR',
          'P7' => 'P7-S&BR',
          'P8' => 'P8-E&GR',
          'P9' => 'P9-M&GNR',
          'P10' => 'P10-G&SWR',
          'P11' => 'P11-B&ER',
          'P12' => 'P12-L&SR',
          'P13' => 'P13-YN&BR',
          'P14' => 'P14-K&TR',
          'P15' => 'P15-HR',
          'P16' => 'P16-Tax Haven',
          'P17' => 'P17-LUR',
          'P18' => 'P18-C&HPR',
          'P19' => 'P19-AEC',
          'P20' => 'P20-C&WR',
          'P21' => 'P21-HSBC',
          'C1' => 'LNWR',
          'C2' => 'GWR',
          'C3' => 'LBSCR',
          'C4' => 'SECR',
          'C5' => 'CR',
          'C6' => 'MR',
          'C7' => 'LYR',
          'C8' => 'NBR',
          'C9' => 'SWR',
          'C10' => 'NER',
          'M1' => '1',
          'M2' => '2',
          'M3' => '3',
          'M4' => '4',
          'M5' => '5',
          'M6' => '6',
          'M7' => '7',
          'M8' => '8',
          'M9' => '9',
          'M10' => '10',
          'M11' => '11',
          'M12' => '12',
          'M13' => '13',
          'M14' => '14',
          'M15' => '15',
          'M16' => '16',
          'M17' => '17',
          'M18' => '18',
          'M19' => '19',
          'M20' => '20',
          'M21' => '21',
          'M22' => '22',
          'M23' => '23',
          'M24' => '24',
          'M25' => '25',
          'M26' => '26',
          'M27' => '27',
          'M28' => '28',
          'M29' => '29',
          'M30' => '30',
        }.freeze

        MAJOR_TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }].freeze

        MERTHYR_TYDFIL_PONTYPOOL_HEX = 'F33'

        MINOR_START_PAR_PRICE = 50
        MINOR_BIDBOX_PRICE = 200
        MINOR_GREEN_UPGRADE = %w[yellow green].freeze

        MINOR_14_ID = '14'

        PLUS_EXPANSION_BIDBOX_1 = %w[P1 P3 P4 P13 P14 P19].freeze
        PLUS_EXPANSION_BIDBOX_2 = %w[P2 P5 P8 P10 P11 P12 P21].freeze
        PLUS_EXPANSION_BIDBOX_3 = %w[P6 P7 P9 P15 P16 P17 P18 P20].freeze

        PRIVATE_COMPANIES_ACQUISITION = {
          'P1' => { acquire: %i[major], phase: 5 },
          'P2' => { acquire: %i[major minor], phase: 2 },
          'P3' => { acquire: %i[major], phase: 2 },
          'P4' => { acquire: %i[major], phase: 2 },
          'P5' => { acquire: %i[major], phase: 3 },
          'P6' => { acquire: %i[major], phase: 3 },
          'P7' => { acquire: %i[major], phase: 3 },
          'P8' => { acquire: %i[major minor], phase: 3 },
          'P9' => { acquire: %i[major minor], phase: 3 },
          'P10' => { acquire: %i[major minor], phase: 3 },
          'P11' => { acquire: %i[major minor], phase: 2 },
          'P12' => { acquire: %i[major minor], phase: 3 },
          'P13' => { acquire: %i[major minor], phase: 5 },
          'P14' => { acquire: %i[major minor], phase: 5 },
          'P15' => { acquire: %i[major minor], phase: 2 },
          'P16' => { acquire: %i[none], phase: 0 },
          'P17' => { acquire: %i[major], phase: 2 },
          'P18' => { acquire: %i[major], phase: 5 },
          'P19' => { acquire: %i[major minor], phase: 1 },
          'P20' => { acquire: %i[major minor], phase: 3 },
          'P21' => { acquire: %i[major minor], phase: 2 },
        }.freeze

        PRIVATE_CLOSE_AFTER_PASS = %w[P12 P21].freeze
        PRIVATE_MAIL_CONTRACTS = %w[P6 P7].freeze
        PRIVATE_REMOVE_REVENUE = %w[P5 P6 P7 P8 P10 P17 P18 P21].freeze
        PRIVATE_PHASE_REVENUE = %w[P15 P20].freeze
        PRIVATE_TRAINS = %w[P1 P3 P4 P13 P14 P19].freeze

        STARTING_COMPANIES = %w[P1 P2 P3 P4 P5 P6 P7 P8 P9 P10 P11 P12 P13 P14 P15 P16 P17 P18
                                C1 C2 C3 C4 C5 C6 C7 C8 C9 C10 M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12 M13 M14 M15
                                M16 16 M17 M18 M19 M20 M21 M22 M23 M24].freeze
        STARTING_COMPANIES_PLUS = %w[P1 P2 P3 P4 P5 P6 P7 P8 P9 P10 P11 P12 P13 P14 P15 P16 P17 P18 P19 P20 P21
                                     C1 C2 C3 C4 C5 C6 C7 C8 C9 C10 M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12 M13 M14 M15
                                     M16 16 M17 M18 M19 M20 M21 M22 M23 M24 M25 M26 M27 M28 M29 M30].freeze

        STARTING_CORPORATIONS = %w[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24
                                   LNWR GWR LBSCR SECR CR MR LYR NBR SWR NER].freeze
        STARTING_CORPORATIONS_PLUS = %w[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29
                                        30 LNWR GWR LBSCR SECR CR MR LYR NBR SWR NER].freeze

        TOKEN_PRICE = 100

        TRACK_PLAIN = %w[7 8 9 80 81 82 83 544 545 546 60 169].freeze
        TRACK_TOWN = %w[3 4 58 141 142 143 144 145 146 147 X17].freeze

        UPGRADABLE_S_YELLOW_CITY_TILE = '57'
        UPGRADABLE_S_YELLOW_ROTATIONS = [2, 5].freeze
        UPGRADABLE_S_HEX_NAME = 'D35'
        UPGRADABLE_T_YELLOW_CITY_TILES = %w[5 6].freeze
        UPGRADABLE_T_HEX_NAMES = %w[B43 K42 M42].freeze

        UPGRADE_COST_L_TO_2 = 80

        include StubsAreRestricted

        attr_accessor :bidding_token_per_player, :player_debts

        def all_potential_upgrades(tile, tile_manifest: false)
          upgrades = super
          return upgrades unless tile_manifest

          upgrades |= [@green_s_tile] if self.class::UPGRADABLE_S_YELLOW_CITY_TILE == tile.name
          upgrades |= [@green_t_tile] if self.class::UPGRADABLE_T_YELLOW_CITY_TILES.include?(tile.name)
          upgrades |= [@sharp_city, @gentle_city] if self.class::UPGRADABLE_T_HEX_NAMES.include?(tile.hex.name)

          upgrades
        end

        def bank_sort(corporations)
          corporations.reject { |c| c.type == :minor }.sort_by(&:name)
        end

        def buying_power(entity, **)
          entity.cash
        end

        def can_hold_above_limit?(_entity)
          true
        end

        def can_par?(corporation, parrer)
          return false if corporation.type == :minor ||
            !(@phase.status.include?('can_convert_concessions') || @phase.status.include?('can_par'))

          super
        end

        def can_run_route?(entity)
          entity.trains.any? { |t| self.class::LOCAL_TRAINS.include?(t.name) } || super
        end

        def check_distance(route, visits)
          english_channel_visit = english_channel_visit(visits)
          # Permanent local train cant run in the english channel
          if self.class::LOCAL_TRAINS.include?(route.train.name) && english_channel_visit.positive?
            raise GameError, 'Local train can not have a route over the english channel'
          end

          # Must visit both hex tiles to be a valid visit. If you are tokened out from france then you cant visit the
          # EC tile either.
          raise GameError, 'Must connect english channel to france' if english_channel_visit == 1

          # Special case when a train just runs english channel to france, this only counts as one visit
          raise GameError, 'Route must have at least 2 stops' if english_channel_visit == 2 && visits.size == 2

          super
        end

        def check_overlap(routes)
          # Tracks by e-train and normal trains
          tracks_by_type = Hash.new { |h, k| h[k] = [] }

          # Check local train not use the same token more then one time
          local_token_hex = []

          # Merthyr Tydfil and Pontypool
          merthyr_tydfil_pontypool = {}

          routes.each do |route|
            if route.train.local? && !route.connections.empty?
              local_token_hex.concat(route.visited_stops.select(&:city?).map { |n| n.hex.id })
            end

            route.paths.each do |path|
              a = path.a
              b = path.b

              tracks = tracks_by_type[train_type(route.train)]
              tracks << [path.hex, a.num, path.lanes[0][1]] if a.edge?
              tracks << [path.hex, b.num, path.lanes[1][1]] if b.edge?

              if b.edge? && a.town? && (nedge = a.tile.preferred_city_town_edges[a]) && nedge != b.num
                tracks << [path.hex, a, path.lanes[0][1]]
              end
              if a.edge? && b.town? && (nedge = b.tile.preferred_city_town_edges[b]) && nedge != a.num
                tracks << [path.hex, b, path.lanes[1][1]]
              end

              if path.hex.id == self.class::MERTHYR_TYDFIL_PONTYPOOL_HEX
                merthyr_tydfil_pontypool[a.num] = true if a.edge?
                merthyr_tydfil_pontypool[b.num] = true if b.edge?
              end
            end
          end

          tracks_by_type.each do |_type, tracks|
            tracks.group_by(&:itself).each do |k, v|
              raise GameError, "Route can't reuse track on #{k[0].id}" if v.size > 1
            end
          end

          local_token_hex.group_by(&:itself).each do |k, v|
            raise GameError, "Local train can only use the token on #{k} once" if v.size > 1
          end

          # Check Merthyr Tydfil and Pontypool, only one of the 2 tracks may be used
          return unless merthyr_tydfil_pontypool[1] && merthyr_tydfil_pontypool[2]

          raise GameError, 'May only use one of the tracks connecting Merthyr Tydfil and Pontypool'
        end

        def company_bought(company, entity)
          # On acquired abilities
          on_acquired_train(company, entity) if self.class::PRIVATE_TRAINS.include?(company.id)
          on_aqcuired_remove_revenue(company) if self.class::PRIVATE_REMOVE_REVENUE.include?(company.id)
          on_aqcuired_phase_revenue(company) if self.class::PRIVATE_PHASE_REVENUE.include?(company.id)
          on_aqcuired_midland_great_northern(company) if self.class::COMPANY_MGNR == company.id
        end

        def company_status_str(company)
          bidbox_minors.each_with_index do |c, index|
            return "Bid box #{index + 1}" if c == company
          end

          bidbox_concessions.each_with_index do |c, index|
            return "Bid box #{index + 1}" if c == company
          end

          if optional_plus_expansion?
            bidbox_privates.each do |c|
              next unless c == company

              return 'Bid box 1' if self.class::PLUS_EXPANSION_BIDBOX_1.include?(c.id)
              return 'Bid box 2' if self.class::PLUS_EXPANSION_BIDBOX_2.include?(c.id)
              return 'Bid box 3' if self.class::PLUS_EXPANSION_BIDBOX_3.include?(c.id)
            end
          else
            bidbox_privates.each_with_index do |c, index|
              return "Bid box #{index + 1}" if c == company
            end
          end

          if self.class::PRIVATE_PHASE_REVENUE.include?(company.id) && company.owner&.player?
            return "(#{format_currency(@phase_revenue[company.id].cash)})"
          end

          if company.id == self.class::COMPANY_OSTH && company.owner&.player? && @tax_haven.value.positive?
            company.value = @tax_haven.value
            share = @tax_haven.shares.first
            return "(#{share.corporation.name})"
          end

          nil
        end

        def compute_other_paths(routes, route)
          routes.flat_map do |r|
            next if r == route || train_type(route.train) != train_type(r.train)

            r.paths
          end
        end

        def crowded_corps
          @crowded_corps ||= corporations.select do |c|
            trains = c.trains.count { |t| !extra_train?(t) }
            trains > train_limit(c)
          end
        end

        def discountable_trains_for(corporation)
          discount_info = super

          corporation.trains.select { |t| t.name == 'L' }.each do |train|
            discount_info << [train, train, '2', self.class::UPGRADE_COST_L_TO_2]
          end
          discount_info
        end

        def end_game!
          company = company_by_id(self.class::COMPANY_OSTH)
          if company && @tax_haven.value.positive?
            # Make sure tax havens value is correct
            company.value = @tax_haven.value
          end

          super
        end

        def entity_can_use_company?(entity, company)
          entity == company.owner
        end

        def event_close_concessions!
          @log << '-- Event: Concessions close --'
          @companies.select { |c| c.id[0] == self.class::COMPANY_CONCESSION_PREFIX && !c.closed? }.each(&:close!)
          @corporations.select { |c| !c.floated? && c.type == :major }.each do |corporation|
            corporation.par_via_exchange = nil
            corporation.float_percent = 50
          end
        end

        def event_full_capitalisation!
          @log << '-- Event: Major companies now receives full capitalisation when floated --'
          @corporations.select { |c| !c.floated? && c.type == :major }.each do |corporation|
            corporation.capitalization = :full
          end
        end

        def event_phase_revenue!
          @log << '-- Event: Highland Railway and Canterbury & Whitstable Railway now closes and its money returned '\
                  'to the bank --'
          self.class::PRIVATE_PHASE_REVENUE.each do |company_id|
            company = @companies.find { |c| c.id == company_id }
            next if !company || company&.closed? || !@phase_revenue[company_id]

            @phase_revenue[company.id].spend(@phase_revenue[company.id].cash, @bank)
            @phase_revenue[company.id] = nil
            company.close!
          end
        end

        def float_corporation(corporation)
          super
          return if !@phase.status.include?('full_capitalisation') || corporation.type != :major

          bundle = ShareBundle.new(corporation.shares_of(corporation))
          @share_pool.transfer_shares(bundle, @share_pool)
          @log << "#{corporation.name}'s remaining shares are transferred to the Market"
        end

        def format_currency(val)
          return super if (val % 1).zero?

          format('£%.1<val>f', val: val)
        end

        def home_token_locations(corporation)
          [hex_by_id(self.class::LONDON_HEX)] if corporation.id == self.class::MINOR_14_ID
        end

        def issuable_shares(entity)
          return [] if !entity.corporation? || (entity.corporation? && entity.type != :major)
          return [] if entity.num_ipo_shares.zero? || entity.operating_history.size < 2

          bundles_for_corporation(entity, entity)
            .select { |bundle| @share_pool.fit_in_bank?(bundle) }
            .map { |bundle| reduced_bundle_price_for_market_drop(bundle) }
        end

        def next_round!
          @round =
            case @round
            when G1822::Round::Choices
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Engine::Round::Stock
              G1822::Round::Choices.new(self, [
                G1822::Step::Choose,
              ], round_num: @round.round_num)
            when Engine::Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                new_stock_round
              end
            when init_round.class
              init_round_finished
              reorder_players
              new_stock_round
            end
        end

        def num_certs(entity)
          certs = super

          # Tax haven does not count towards cert limit
          company = entity.companies.find { |c| c.id == self.class::COMPANY_OSTH }
          certs -= 1 if company
          certs
        end

        def tile_lays(entity)
          return self.class::COMPANY_HSBC_TILE_LAYS if entity.id == self.class::COMPANY_HSBC

          operator = entity.company? ? entity.owner : entity
          if @phase.name.to_i >= 3 && operator.corporation? && operator.type == :major
            return self.class::MAJOR_TILE_LAYS
          end

          super
        end

        def train_help(runnable_trains)
          return [] if runnable_trains.empty?

          entity = runnable_trains.first.owner

          # L - trains
          l_trains = runnable_trains.any? { |t| self.class::LOCAL_TRAINS.include?(t.name) }

          # Destination bonues
          destination_token = nil
          destination_token = entity.tokens.find { |t| t.used && t.type == :destination } if entity.type == :major

          # Mail contract
          mail_contracts = entity.companies.any? { |c| self.class::PRIVATE_MAIL_CONTRACTS.include?(c.id) }

          help = []
          help << "L (local) trains run in a city which has a #{entity.name} token. "\
                  'They can additionally run to a single small station, but are not required to do so. '\
                  'They can thus be considered 1 (+1) trains. '\
                  'Only one L train may operate on each station token.' if l_trains

          help << 'When a train runs between its home station token and its destination station token it doubles the '\
                  'value of its destination station. This only applies to one train per operating '\
                  'turn.' if destination_token

          help << 'Mail contract(s) gives a subsidy equal to one half of the base value of the start and end '\
                  'stations from one of the trains operated. Doubled values (for E trains or destination tokens) '\
                  'do not count.' if mail_contracts
          help
        end

        def init_companies(players)
          # Make sure we have the correct starting companies
          starting_companies = if optional_plus_expansion?
                                 self.class::STARTING_COMPANIES_PLUS
                               else
                                 self.class::STARTING_COMPANIES
                               end
          game_companies.map do |company|
            next if players.size < (company[:min_players] || 0)
            next unless starting_companies.include?(company[:sym])

            Company.new(**company)
          end.compact
        end

        def init_company_abilities
          @companies.each do |company|
            next unless (ability = abilities(company, :exchange))
            next unless ability.from.include?(:par)

            exchange_corporations(ability).first.par_via_exchange = company
          end

          super
        end

        def init_corporations(stock_market)
          # Make sure we have the correct starting corporations
          starting_corporations = if optional_plus_expansion?
                                    self.class::STARTING_CORPORATIONS_PLUS
                                  else
                                    self.class::STARTING_CORPORATIONS
                                  end
          game_corporations.map do |corporation|
            next unless starting_corporations.include?(corporation[:sym])

            Corporation.new(
              min_price: stock_market.par_prices.map(&:price).min,
              capitalization: self.class::CAPITALIZATION,
              **corporation.merge(corporation_opts),
            )
          end.compact
        end

        def init_hexes(_companies, _corporations)
          hexes = super

          self.class::DESTINATIONS.each do |corp, destination|
            hexes.find { |h| h.id == destination }.tile.icons << Part::Icon.new("../icons/1822/#{corp}_DEST",
                                                                                "#{corp}_destination")
          end

          hexes
        end

        def init_round
          stock_round
        end

        def must_buy_train?(entity)
          entity.trains.none? { |t| !extra_train?(t) } &&
          !depot.depot_trains.empty?
        end

        # TODO: [1822] Make include with 1861, 1867
        def operating_order
          minors, majors = @corporations.select(&:floated?).sort.partition { |c| c.type == :minor }
          minors + majors
        end

        def operating_round(round_num)
          G1822::Round::Operating.new(self, [
            G1822::Step::PendingToken,
            G1822::Step::FirstTurnHousekeeping,
            Engine::Step::AcquireCompany,
            Engine::Step::DiscardTrain,
            G1822::Step::SpecialChoose,
            G1822::Step::SpecialTrack,
            G1822::Step::SpecialToken,
            G1822::Step::Track,
            G1822::Step::DestinationToken,
            G1822::Step::Token,
            G1822::Step::Route,
            G1822::Step::Dividend,
            G1822::Step::BuyTrain,
            G1822::Step::MinorAcquisition,
            G1822::Step::PendingToken,
            Engine::Step::DiscardTrain,
            G1822::Step::IssueShares,
          ], round_num: round_num)
        end

        def payout_companies
          # Set the correct revenue of Highland Railway and Midland & Great Northern
          @companies.each do |c|
            next unless c.owner

            if self.class::PRIVATE_PHASE_REVENUE.include?(c.id)
              multiplier = if c.id == self.class::COMPANY_HR
                             10
                           elsif c.id == self.class::COMPANY_CWR
                             5
                           end
              revenue = @phase.name.to_i * multiplier
              c.revenue = revenue
              @bank.spend(revenue, @phase_revenue[c.id])
              @log << "#{c.name} collects #{format_currency(revenue)}"
            end

            if c.id == self.class::COMPANY_MGNR && c.owner.corporation?
              c.revenue = self.class::COMPANY_MGNR_REVENUE[@phase.name.to_i]
            end
          end

          super
        end

        def place_home_token(corporation)
          return if corporation.tokens.first&.used

          super

          # Special for LNWR, it gets its destination token. But wont get the bonus until home
          # and destination is connected
          return unless corporation.id == 'LNWR'

          hex = hex_by_id(self.class::DESTINATIONS[corporation.id])
          token = corporation.find_token_by_type(:destination)
          place_destination_token(corporation, hex, token)
        end

        def player_value(player)
          player.value - @player_debts[player]
        end

        def purchasable_companies(entity = nil)
          return [] unless entity

          @companies.select do |company|
            company.owner&.player? && entity != company.owner && !company.closed? && !abilities(company, :no_buy) &&
              acquire_private_company?(entity, company)
          end
        end

        def redeemable_shares(entity)
          return [] if !entity.corporation? || (entity.corporation? && entity.type != :major)

          bundles_for_corporation(@share_pool, entity).reject { |bundle| entity.cash < bundle.price }
        end

        def reorder_players(_order = nil)
          current_order = @players.dup.reverse
          @players.sort_by! do |p|
            cash = p.cash
            cash *= 2 if @midland_great_northern_choice == p
            [cash, current_order.index(p)]
          end.reverse!

          player_order = @players.map do |p|
            double = ' doubled' if @midland_great_northern_choice == p
            "#{p.name} (#{format_currency(p.cash)}#{double})"
          end.join(', ')

          @log << "-- New player order: #{player_order}"

          # Reset the choice for Midland & Great Northern Joint Railway
          @midland_great_northern_choice = nil
        end

        def revenue_for(route, stops)
          if route.hexes.size != route.hexes.uniq.size &&
              route.hexes.none? { |h| self.class::DOUBLE_HEX.include?(h.name) }
            raise GameError, 'Route visits same hex twice'
          end

          revenue = if train_type(route.train) == :normal
                      super
                    else
                      entity = route.train.owner
                      france_stop = stops.find { |s| s.offboard? && s.hex.name == self.class::FRANCE_HEX }
                      stops.sum do |stop|
                        next 0 unless stop.city?

                        tokened = stop.tokened_by?(entity)
                        # If we got a token in English channel, calculate the revenue from the france offboard
                        if tokened && stop.hex.name == self.class::ENGLISH_CHANNEL_HEX
                          france_stop ? france_stop.route_revenue(route.phase, route.train) : 0
                        elsif tokened
                          stop.route_revenue(route.phase, route.train)
                        else
                          0
                        end
                      end
                    end
          destination_bonus = destination_bonus(route.routes)
          revenue += destination_bonus[:revenue] if destination_bonus && destination_bonus[:route] == route
          revenue
        end

        def revenue_str(route)
          str = super

          destination_bonus = destination_bonus(route.routes)
          if destination_bonus && destination_bonus[:route] == route
            str += " (#{format_currency(destination_bonus[:revenue])})"
          end

          str
        end

        def routes_subsidy(routes)
          return 0 if routes.empty?

          mail_bonus = mail_contract_bonus(routes.first.train.owner, routes)
          return 0 if mail_bonus.empty?

          mail_bonus.sum do |v|
            v[:subsidy]
          end
        end

        def route_trains(entity)
          entity.runnable_trains.reject { |t| pullman_train?(t) }
        end

        def setup
          # Setup the bidding token per player
          @bidding_token_per_player = init_bidding_token

          # Init all the special upgrades
          @sharp_city ||= @tiles.find { |t| t.name == '5' }
          @gentle_city ||= @tiles.find { |t| t.name == '6' }
          @green_s_tile ||= @tiles.find { |t| t.name == 'X3' }
          @green_t_tile ||= @tiles.find { |t| t.name == '405' }

          # Initialize the extra city which minor 14 might add
          @london_extra_city_index = nil

          # Initialize the player depts, if player have to take an emergency loan
          @player_debts = Hash.new { |h, k| h[k] = 0 }

          # Initialize a dummy player for Highland Railway and Canterbury and Whitstable Railway
          # to hold the cash it generates
          @phase_revenue = {}
          self.class::PRIVATE_PHASE_REVENUE.each do |company_id|
            @phase_revenue[company_id] = Engine::Player.new(-1, company_id)
          end

          # Initialize a dummy player for Tax haven to hold the share and the cash it generates
          @tax_haven = Engine::Player.new(-1, 'Tax Haven')

          # Initialize the stock round choice for Midland & Great Northern Joint Railway
          @midland_great_northern_choice = nil

          # Randomize and setup the companies
          setup_companies

          # Setup the fist bidboxes
          @bidbox_minors_cache = []
          setup_bidboxes

          # Setup exchange token abilities for all corporations
          setup_exchange_tokens

          # Setup all the destination tokens, icons and abilities
          setup_destinations
        end

        def sorted_corporations
          phase = @phase.status.include?('can_convert_concessions') || @phase.status.include?('can_par')
          return [] unless phase

          ipoed, others = @corporations.select { |c| c.type == :major }.partition(&:ipoed)
          ipoed.sort + others
        end

        def status_str(corporation)
          return if corporation.type != :minor || !corporation.share_price

          "Market value #{format_currency(corporation.share_price.price)}"
        end

        def stock_round
          G1822::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1822::Step::BuySellParShares,
          ])
        end

        def timeline
          timeline = []

          minors = timeline_companies(self.class::COMPANY_MINOR_PREFIX, bidbox_minors)
          timeline << "Minors: #{minors.join(', ')}" unless minors.empty?

          concessions = timeline_companies(self.class::COMPANY_CONCESSION_PREFIX, bidbox_concessions)
          timeline << "Concessions: #{concessions.join(', ')}" unless concessions.empty?

          if optional_plus_expansion?
            b1_privates = timeline_companies_plus(self.class::COMPANY_PRIVATE_PREFIX,
                                                  self.class::PLUS_EXPANSION_BIDBOX_1)
            timeline << "Privates bidbox 1 : #{b1_privates.join(', ')}" unless b1_privates.empty?

            b2_privates = timeline_companies_plus(self.class::COMPANY_PRIVATE_PREFIX,
                                                  self.class::PLUS_EXPANSION_BIDBOX_2)
            timeline << "Privates bidbox 2: #{b2_privates.join(', ')}" unless b2_privates.empty?

            b3_privates = timeline_companies_plus(self.class::COMPANY_PRIVATE_PREFIX,
                                                  self.class::PLUS_EXPANSION_BIDBOX_3)
            timeline << "Privates bidbox 3: #{b3_privates.join(', ')}" unless b3_privates.empty?
          else
            privates = timeline_companies(self.class::COMPANY_PRIVATE_PREFIX, bidbox_privates)
            timeline << "Privates: #{privates.join(', ')}" unless privates.empty?
          end

          timeline
        end

        def timeline_companies(prefix, bidbox_companies)
          bank_companies(prefix).map do |company|
            "#{self.class::COMPANY_SHORT_NAMES[company.id]}#{'*' if bidbox_companies.any? { |c| c == company }}"
          end
        end

        def timeline_companies_plus(prefix, bidbox)
          first = true
          bank_companies(prefix).map do |company|
            next unless bidbox.include?(company.id)

            company_str = "#{self.class::COMPANY_SHORT_NAMES[company.id]}#{'*' if first}"
            first = false
            company_str
          end.compact
        end

        def unowned_purchasable_companies(_entity)
          minors = bank_companies(self.class::COMPANY_MINOR_PREFIX)
          concessions = bank_companies(self.class::COMPANY_CONCESSION_PREFIX)
          privates = bank_companies(self.class::COMPANY_PRIVATE_PREFIX)
          minors + concessions + privates
        end

        def upgrade_cost(tile, hex, entity)
          abilities = entity.all_abilities.select do |a|
            a.type == :tile_discount && (!a.hexes || a.hexes.include?(hex.name))
          end

          tile.upgrades.sum do |upgrade|
            total_cost = upgrade.cost
            abilities.each do |ability|
              discount = ability && upgrade.terrains.uniq == [ability.terrain] ? ability.discount : 0
              log_cost_discount(entity, ability, discount)
              total_cost -= discount
            end
            total_cost
          end
        end

        def upgrades_to?(from, to, special = false)
          # Check the S hex and potential upgrades
          if self.class::UPGRADABLE_S_HEX_NAME == from.hex.name && from.color == :white
            return self.class::UPGRADABLE_S_YELLOW_CITY_TILE == to.name
          end

          if self.class::UPGRADABLE_S_HEX_NAME == from.hex.name &&
            self.class::UPGRADABLE_S_YELLOW_CITY_TILE == from.name
            return to.name == 'X3'
          end

          # Check the T hexes and potential upgrades
          if self.class::UPGRADABLE_T_HEX_NAMES.include?(from.hex.name) && from.color == :white
            return self.class::UPGRADABLE_T_YELLOW_CITY_TILES.include?(to.name)
          end

          if self.class::UPGRADABLE_T_HEX_NAMES.include?(from.hex.name) &&
            self.class::UPGRADABLE_T_YELLOW_CITY_TILES.include?(from.name)
            return to.name == '405'
          end

          # Special case for Middleton Railway where we remove a town from a tile
          if self.class::TRACK_TOWN.include?(from.name) && self.class::TRACK_PLAIN.include?(to.name)
            return Engine::Tile::COLORS.index(to.color) == (Engine::Tile::COLORS.index(from.color) + 1)
          end

          super
        end

        def acquire_private_company?(entity, company)
          company_acquisition = self.class::PRIVATE_COMPANIES_ACQUISITION[company.id]
          return false unless company_acquisition

          @phase.name.to_i >= company_acquisition[:phase] && company_acquisition[:acquire].include?(entity.type)
        end

        def add_exchange_token(entity)
          ability = entity.all_abilities.find { |a| a.type == :exchange_token }
          count = ability ? ability.count + 1 : 1
          new_ability = Ability::Base.new(
            type: 'exchange_token',
            description: "Exchange tokens: #{count}",
            count: count
          )
          entity.remove_ability(ability) if ability
          entity.add_ability(new_ability)
        end

        def add_interest_player_loans!
          @player_debts.each do |player, loan|
            next unless loan.positive?

            interest = player_loan_interest(loan)
            new_loan = loan + interest
            @player_debts[player] = new_loan
            @log << "#{player.name} increases its loan by 50% (#{format_currency(interest)}) to "\
                    "#{format_currency(new_loan)}"
          end
        end

        def after_place_pending_token(city)
          return unless city.hex.name == self.class::LONDON_HEX

          # Save the extra token city index in london. We need this if we acquire the minor 14 and chooses to remove
          # the token from london. The city where the 14's home token used to be is now open for other companies to
          # token. If we do an upgrade to london, make sure this city still is open.
          @london_extra_city_index = city.tile.cities.index { |c| c == city }
        end

        def after_lay_tile(hex, tile)
          # If we upgraded london, check if we need to add the extra slot from minor 14
          upgrade_london(hex) if hex.name == self.class::LONDON_HEX

          # If we upgraded the english channel to brown, upgrade france as well since we got 2 lanes to france.
          return unless hex.name == self.class::ENGLISH_CHANNEL_HEX && tile.color == :brown

          upgrade_france_to_brown
        end

        def after_track_pass(entity)
          # Special case of when we only used up one of the 2 track lays of
          # Leicester & Swannington Railway or Humber Suspension Bridge Company
          self.class::PRIVATE_CLOSE_AFTER_PASS.each do |company_id|
            company = entity.companies.find { |c| c.id == company_id }
            next unless company

            count = company.all_abilities.find { |a| a.type == :tile_lay }&.count
            next if !count || count == 2

            @log << "#{company.name} closes"
            company.close!
          end
        end

        def bank_companies(prefix)
          @companies.select do |c|
            c.id[0] == prefix && (!c.owner || c.owner == @bank) && !c.closed?
          end
        end

        def bidbox_minors
          bank_companies(self.class::COMPANY_MINOR_PREFIX)
            .first(self.class::BIDDING_BOX_MINOR_COUNT)
            .select do |company|
            @bidbox_minors_cache.include?(company.id)
          end
        end

        def bidbox_concessions
          bank_companies(self.class::COMPANY_CONCESSION_PREFIX).first(self.class::BIDDING_BOX_CONCESSION_COUNT)
        end

        def bidbox_privates
          if optional_plus_expansion?
            companies = bank_companies(self.class::COMPANY_PRIVATE_PREFIX)
            privates = []
            privates << companies.find { |c| self.class::PLUS_EXPANSION_BIDBOX_1.include?(c.id) }
            privates << companies.find { |c| self.class::PLUS_EXPANSION_BIDBOX_2.include?(c.id) }
            privates << companies.find { |c| self.class::PLUS_EXPANSION_BIDBOX_3.include?(c.id) }
            privates.compact
          else
            bank_companies(self.class::COMPANY_PRIVATE_PREFIX).first(self.class::BIDDING_BOX_PRIVATE_COUNT)
          end
        end

        def bidbox_minors_refill!
          @bidbox_minors_cache = bank_companies(self.class::COMPANY_MINOR_PREFIX)
                                   .first(self.class::BIDDING_BOX_MINOR_COUNT)
                                   .map(&:id)
        end

        def can_gain_extra_train?(entity, train)
          if train.name == self.class::EXTRA_TRAIN_PULLMAN
            return false if entity.trains.any? { |t| t.name == self.class::EXTRA_TRAIN_PULLMAN }
          elsif self.class::EXTRA_TRAIN_PERMANENTS.include?(train.name)
            return false if entity.trains.any? { |t| self.class::EXTRA_TRAIN_PERMANENTS.include?(t.name) }
          end
          true
        end

        def calculate_destination_bonus(route)
          entity = route.train.owner
          # Only majors can have a destination token
          return nil unless entity.type == :major

          # Check if the corporation have placed its destination token
          destination_token = entity.tokens.find { |t| t.used && t.type == :destination }
          return nil unless destination_token

          # First token is always the hometoken
          home_token = entity.tokens.first
          token_count = 0
          route.visited_stops.each do |stop|
            next unless stop.city?

            token_count += 1 if stop.tokens.any? { |t| t == home_token || t == destination_token }
          end

          # Both hometoken and destination token must be in the route to get the destination bonus
          return nil unless token_count == 2

          { route: route, revenue: destination_token.city.route_revenue(route.phase, route.train) }
        end

        def choices_entities
          company = company_by_id(self.class::COMPANY_MGNR)
          return [] unless company&.owner&.player?

          [company.owner]
        end

        def player_loan_interest(loan)
          (loan * 0.5).ceil
        end

        def company_ability_extra_track?(company)
          company.id == self.class::COMPANY_LSR
        end

        def company_choices(company, time)
          case company.id
          when self.class::COMPANY_CHPR
            company_choices_chpr(company, time)
          when self.class::COMPANY_EGR
            company_choices_egr(company, time)
          when self.class::COMPANY_LCDR
            company_choices_lcdr(company, time)
          when self.class::COMPANY_LUR
            company_choices_lur(company, time)
          when self.class::COMPANY_MGNR
            company_choices_mgnr(company, time)
          when self.class::COMPANY_OSTH
            company_choices_osth(company, time)
          else
            {}
          end
        end

        def company_choices_chpr(company, time)
          return {} if !(time == :token || time == :track) || !company.owner&.corporation?

          choices = {}
          exchange_token_count = exchange_tokens(company.owner)
          choices['exchange'] = 'Move an exchange token to the available section' if exchange_token_count.positive?
          if !company.owner.tokens_by_type.empty? &&
            exchange_token_count < self.class::EXCHANGE_TOKENS[company.owner.id]
            choices['available'] = 'Move an available token to the exchange section'
          end
          choices
        end

        def company_choices_egr(company, time)
          return {} if !company.all_abilities.empty? || time != :special_choose

          choices = {}
          choices['token'] = 'Receive a discount token that can be used to pay the full cost of a single '\
                             'track tile lay on a rough terrain, hill or mountain hex.'
          choices['discount'] = 'Receive a £20 continuous discount off the cost of all hill and mountain terrain '\
                                '(i.e. NOT off the cost of rough terrain).'
          choices
        end

        def company_choices_lcdr(company, time)
          return {} if time != :token || !company.owner&.corporation?

          choices = {}
          choices['exchange'] = 'Move an exchange station token to the available station token section'
          choices
        end

        def company_choices_lur(company, time)
          return {} if time != :issue || !company.owner&.corporation?

          exclude_minors = bidbox_minors
          exclude_concessions = bidbox_concessions
          exclude_privates = bidbox_privates

          minors_choices = company_choices_lur_companies(self.class::COMPANY_MINOR_PREFIX, exclude_minors)
          concessions_choices = company_choices_lur_companies(self.class::COMPANY_CONCESSION_PREFIX,
                                                              exclude_concessions)
          privates_choices = company_choices_lur_companies(self.class::COMPANY_PRIVATE_PREFIX, exclude_privates)

          choices = {}
          choices.merge!(minors_choices)
          choices.merge!(concessions_choices)
          choices.merge!(privates_choices)
          choices.compact
        end

        def company_choices_lur_companies(prefix, exclude_companies)
          choices = {}
          companies = bank_companies(prefix).reject do |company|
            exclude_companies.any? { |c| c == company }
          end
          companies.each do |company|
            choices["#{company.id}_top"] = "#{self.class::COMPANY_SHORT_NAMES[company.id]}-Top"
            choices["#{company.id}_bottom"] = "#{self.class::COMPANY_SHORT_NAMES[company.id]}-Bottom"
          end
          choices
        end

        def company_choices_mgnr(company, time)
          return {} if @midland_great_northern_choice || !company.owner&.player? || time != :choose

          choices = {}
          choices['double'] = 'Double your actual cash holding when determining player turn order.'
          choices
        end

        def company_choices_osth(company, time)
          return {} if @tax_haven.value.positive? || !company.owner&.player? || time != :stock_round

          choices = {}
          @corporations.select { |c| c.floated? && c.type == :major }.each do |corporation|
            price = corporation.share_price&.price || 0
            if corporation.num_ipo_shares.positive?
              choices["#{corporation.id}_ipo"] = "#{corporation.id} IPO (#{format_currency(price)})"
            end
            if @share_pool.num_shares_of(corporation).positive?
              choices["#{corporation.id}_market"] = "#{corporation.id} Market (#{format_currency(price)})"
            end
          end
          choices
        end

        def company_made_choice(company, choice, time)
          case company.id
          when self.class::COMPANY_EGR
            company_made_choice_egr(company, choice, time)
          when self.class::COMPANY_MGNR
            company_made_choice_mgnr(company)
          when self.class::COMPANY_LCDR
            company_made_choice_lcdr(company)
          when self.class::COMPANY_LUR
            company_made_choice_lur(company, choice)
          when self.class::COMPANY_CHPR
            company_made_choice_chpr(company, choice)
          when self.class::COMPANY_OSTH
            company_made_choice_osth(company, choice)
          end
        end

        def company_made_choice_chpr(company, choice)
          if choice == 'exchange'
            move_exchange_token(company.owner)
            @log << "#{company.owner.name} moves an exchange token into to the available station token section"
          else
            corporation = company.owner
            corporation.find_token_by_type.destroy!
            add_exchange_token(corporation)
            @log << "#{company.owner.name} moves an available token into to the exchange station token section"
          end
          @log << "#{company.name} closes"
          company.close!
        end

        def company_made_choice_egr(company, choice, time)
          company.desc = company_choices(company, time)[choice]
          if choice == 'token'
            # Give the company a free tile lay.
            ability = Engine::Ability::TileLay.new(type: 'tile_lay', tiles: [], hexes: [], owner_type: 'corporation',
                                                   count: 1, closed_when_used_up: true, reachable: true, free: true,
                                                   special: false, when: 'track')
            company.add_ability(ability)
          else
            %w[mountain hill].each do |terrain|
              ability = Engine::Ability::TileDiscount.new(type: 'tile_discount', discount: 20, terrain: terrain)
              company.add_ability(ability)
            end
          end
        end

        def company_made_choice_lcdr(company)
          move_exchange_token(company.owner)
          @log << "#{company.owner.name} moves an exchange token into to the available station token section"
          @log << "#{company.name} closes"
          company.close!
        end

        def company_made_choice_lur(company, choice)
          choice_array = choice.split('_')
          selected_company = company_by_id(choice_array[0])
          top = choice_array[1] == 'top'

          @companies.delete(selected_company)
          if top
            last_bid_box_company = if selected_company.id[0] == self.class::COMPANY_MINOR_PREFIX
                                     bidbox_minors&.last
                                   elsif selected_company.id[0] == self.class::COMPANY_CONCESSION_PREFIX
                                     bidbox_concessions&.last
                                   else
                                     bidbox_privates&.last
                                   end
            index = @companies.index { |c| c == last_bid_box_company }
            @companies.insert(index + 1, selected_company)
          else
            @companies << selected_company
          end

          @log << "#{company.owner.name} moves #{selected_company.name} to the #{top ? 'top' : 'bottom'}"
          @log << "#{company.name} closes"
          company.close!
        end

        def company_made_choice_mgnr(company)
          @midland_great_northern_choice = company.owner
          @log << "#{company.owner.name} chooses to double actual cash holding when determining player turn order."
        end

        def company_made_choice_osth(company, choice)
          spender = company.owner
          bundle = company_tax_haven_bundle(choice)
          corporation = bundle.corporation
          @share_pool.transfer_shares(bundle, @tax_haven, spender: spender, receiver: corporation,
                                                          price: bundle.price, allow_president_change: false)
          @log << "#{spender.name} spends #{format_currency(bundle.price)} and tax haven gains a share of "\
                  "#{corporation.name}."
        end

        def company_tax_haven_bundle(choice)
          choice_array = choice.split('_')
          corporation = corporation_by_id(choice_array[0])
          share = choice_array[1] == 'ipo' ? corporation.ipo_shares.first : @share_pool.shares_of(corporation).first
          ShareBundle.new(share)
        end

        def company_tax_haven_payout(entity, per_share)
          return unless @tax_haven.value.positive?

          amount = @tax_haven.num_shares_of(entity) * per_share
          return unless amount.positive?

          @bank.spend(amount, @tax_haven)
          @log << "#{entity.name} pays out #{format_currency(amount)} to tax haven"
        end

        def destination_bonus(routes)
          return nil if routes.empty?

          # If multiple routes gets destination bonus, get the biggest one. If we got E trains
          # this is bigger then normal train.
          destination_bonus = routes.map { |r| calculate_destination_bonus(r) }.compact
          destination_bonus.sort_by { |v| v[:revenue] }.reverse&.first
        end

        def english_channel_visit(visits)
          visits.count { |v| v.hex.name == self.class::ENGLISH_CHANNEL_HEX || v.hex.name == self.class::FRANCE_HEX }
        end

        def exchange_tokens(entity)
          return 0 unless entity.corporation?

          ability = entity.all_abilities.find { |a| a.type == :exchange_token }
          return 0 unless ability

          ability.count
        end

        def extra_train?(train)
          self.class::EXTRA_TRAINS.include?(train.name)
        end

        def find_corporation(company)
          corporation_id = company.id[1..-1]
          corporation_by_id(corporation_id)
        end

        def init_bidding_token
          self.class::BIDDING_TOKENS[@players.size.to_s]
        end

        def london_extra_token_ability
          Engine::Ability::Token.new(type: 'token', hexes: [], price: 20, cheater: 1)
        end

        def mail_contract_bonus(entity, routes)
          mail_contracts = entity.companies.count { |c| self.class::PRIVATE_MAIL_CONTRACTS.include?(c.id) }
          return [] unless mail_contracts.positive?

          mail_bonuses = routes.map do |r|
            stops = r.visited_stops
            next if stops.size < 2

            first = stops.first.route_base_revenue(r.phase, r.train) / 2
            last = stops.last.route_base_revenue(r.phase, r.train) / 2
            { route: r, subsidy: first + last }
          end.compact
          mail_bonuses.sort_by { |v| v[:subsidy] }.reverse.take(mail_contracts)
        end

        def move_exchange_token(entity)
          remove_exchange_token(entity)
          entity.tokens << Engine::Token.new(entity, price: self.class::TOKEN_PRICE)
        end

        def on_aqcuired_phase_revenue(company)
          revenue_player = @phase_revenue[company.id]
          @log << "#{company.owner.name} gains #{format_currency(revenue_player.cash)}"
          revenue_player.spend(revenue_player.cash, company.owner)
          @phase_revenue[company.id] = nil
          @log << "#{company.name} closes"
          company.close!
        end

        def on_aqcuired_midland_great_northern(company)
          company.revenue = self.class::COMPANY_MGNR_REVENUE[@phase.name.to_i]
        end

        def on_aqcuired_remove_revenue(company)
          company.revenue = 0
        end

        def on_acquired_train(company, entity)
          train = @company_trains[company.id]

          unless can_gain_extra_train?(entity, train)
            raise GameError, "Can't gain an extra #{train.name}, already have a permanent 2P or LP"
          end

          buy_train(entity, train, :free)
          @log << "#{entity.name} gains a #{train.name} train"

          # Company closes after it is flipped into a train
          company.close!
          @log << "#{company.name} closes"
        end

        def optional_plus_expansion?
          @optional_rules&.include?(:plus_expansion)
        end

        def payoff_player_loan(player)
          # Remove the loan money from the player. The money from loans is outside money, doesnt count towards
          # the normal bank money.
          player.cash -= @player_debts[player]
          @player_debts[player] = 0
        end

        def place_destination_token(entity, hex, token)
          city = hex.tile.cities.first
          city.place_token(entity, token, free: true, check_tokenable: false, cheater: 0)
          hex.tile.icons.reject! { |icon| icon.name == "#{entity.id}_destination" }

          ability = entity.all_abilities.find { |a| a.type == :destination }
          entity.remove_ability(ability)

          @graph.clear

          @log << "#{entity.name} places its destination token on #{hex.name}"
        end

        def player_debt(player)
          @player_debts[player] || 0
        end

        def pullman_train?(train)
          train.name == self.class::EXTRA_TRAIN_PULLMAN
        end

        def reduced_bundle_price_for_market_drop(bundle)
          directions = (1..bundle.num_shares).map { |_| :up }
          bundle.share_price = @stock_market.find_share_price(bundle.corporation, directions).price
          bundle
        end

        def setup_bidboxes
          # Set the owner to bank for the companies up for auction this stockround
          bidbox_minors_refill!
          bidbox_minors.each do |minor|
            minor.owner = @bank
          end

          bidbox_concessions.each do |concessions|
            concessions.owner = @bank
          end

          bidbox_privates.each do |company|
            company.owner = @bank
          end

          # Reset the choice for Midland & Great Northern Joint Railway
          @midland_great_northern_choice = nil
        end

        def remove_exchange_token(entity)
          ability = entity.all_abilities.find { |a| a.type == :exchange_token }
          ability.use!
          ability.description = "Exchange tokens: #{ability.count}"
        end

        def take_player_loan(player, loan)
          # Give the player the money. The money for loans is outside money, doesnt count towards the normal bank money.
          player.cash += loan

          # Add interest to the loan, must atleast pay 150% of the loaned value
          @player_debts[player] += loan + player_loan_interest(loan)
        end

        def train_type(train)
          train.name == 'E' ? :etrain : :normal
        end

        def upgrade_france_to_brown
          france_tile = Engine::Tile.from_code(self.class::FRANCE_HEX, :gray, self.class::FRANCE_HEX_BROWN_TILE)
          france_tile.location_name = 'France'
          hex_by_id(self.class::FRANCE_HEX).tile = france_tile
        end

        def upgrade_london(hex)
          return unless @london_extra_city_index

          extra_city = hex.tile.cities[@london_extra_city_index]
          return unless extra_city.tokens.size == 1

          extra_city.tokens[extra_city.normal_slots] = nil
        end

        private

        def find_and_remove_train_by_id(train_id, buyable: true)
          train = train_by_id(train_id)
          @depot.remove_train(train)
          train.buyable = buyable
          train
        end

        def setup_companies
          # Randomize from preset seed to get same order
          @companies.sort_by! { rand }

          minors = @companies.select { |c| c.id[0] == self.class::COMPANY_MINOR_PREFIX }
          concessions = @companies.select { |c| c.id[0] == self.class::COMPANY_CONCESSION_PREFIX }
          privates = @companies.select { |c| c.id[0] == self.class::COMPANY_PRIVATE_PREFIX }

          # Always set the P1, C1 and M24 in the first biddingbox
          m24 = minors.find { |c| c.id == self.class::BIDDING_BOX_START_MINOR }
          minors.delete(m24)
          minors.unshift(m24)

          c1 = concessions.find { |c| c.id == self.class::BIDDING_BOX_START_CONCESSION }
          concessions.delete(c1)
          concessions.unshift(c1)

          p1 = privates.find { |c| c.id == self.class::BIDDING_BOX_START_PRIVATE }
          privates.delete(p1)
          privates.unshift(p1)

          # If have have activated 1822+, 3 companies will be removed from the game
          if optional_plus_expansion?
            # Make sure we have correct order of the bidboxes
            bid_box_1 = privates.map { |c| c if self.class::PLUS_EXPANSION_BIDBOX_1.include?(c.id) }.compact
            bid_box_2 = privates.map { |c| c if self.class::PLUS_EXPANSION_BIDBOX_2.include?(c.id) }.compact
            bid_box_3 = privates.map { |c| c if self.class::PLUS_EXPANSION_BIDBOX_3.include?(c.id) }.compact
            privates = bid_box_1 + bid_box_2 + bid_box_3

            # Remove one of the bidbid 2 privates, except London, Chatham and Dover Railway
            company = privates.find do |c|
              c.id != self.class::COMPANY_LCDR && self.class::PLUS_EXPANSION_BIDBOX_2.include?(c.id)
            end
            privates.delete(company)
            @log << "#{company.id}-#{company.name} have been removed from the game"

            # Remove two of the bidbox 3 privates
            2.times.each do |_|
              company = privates.find { |c| self.class::PLUS_EXPANSION_BIDBOX_3.include?(c.id) }
              privates.delete(company)
              @log << "#{company.id}-#{company.name} have been removed from the game"
            end
          end

          # Clear and add the companies in the correct randomize order sorted by type
          @companies.clear
          @companies.concat(minors)
          @companies.concat(concessions)
          @companies.concat(privates)

          # Set the min bid on the Concessions and Minors
          @companies.each do |c|
            case c.id[0]
            when self.class::COMPANY_CONCESSION_PREFIX, self.class::COMPANY_MINOR_PREFIX
              c.min_price = c.value
            else
              c.min_price = 0
            end
            c.max_price = 10_000
          end

          # Setup company abilities
          @company_trains = {}
          @company_trains['P3'] = find_and_remove_train_by_id('2P-0', buyable: false)
          @company_trains['P4'] = find_and_remove_train_by_id('2P-1', buyable: false)
          @company_trains['P1'] = find_and_remove_train_by_id('5P-0')
          @company_trains['P13'] = find_and_remove_train_by_id('P+-0', buyable: false)
          @company_trains['P14'] = find_and_remove_train_by_id('P+-1', buyable: false)
          @company_trains['P19'] = find_and_remove_train_by_id('LP-0', buyable: false)

          # Setup the minor 14 ability
          corporation_by_id(self.class::MINOR_14_ID).add_ability(london_extra_token_ability)
        end

        def setup_destinations
          self.class::DESTINATIONS.each do |corp, destination|
            description = if corp == 'LNWR'
                            "Gets destination token at #{destination} when floated"
                          else
                            "Connect to #{destination} for your destination token"
                          end
            ability = Ability::Base.new(
              type: 'destination',
              description: description
            )
            corporation = corporation_by_id(corp)
            corporation.add_ability(ability)
            corporation.tokens << Engine::Token.new(corporation, logo: "/logos/1822/#{corp}_DEST.svg",
                                                                 simple_logo: "/logos/1822/#{corp}_DEST.svg",
                                                                 type: :destination)
          end
        end

        def setup_exchange_tokens
          self.class::EXCHANGE_TOKENS.each do |corp, token_count|
            ability = Ability::Base.new(
              type: 'exchange_token',
              description: "Exchange tokens: #{token_count}",
              count: token_count
            )
            corporation = corporation_by_id(corp)
            corporation.add_ability(ability)
          end
        end
      end
    end
  end
end
