# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G18SJ
      class Game < Game::Base
        include_meta(G18SJ::Meta)

        register_colors(
          black: '#0a0a0a', # STJ
          brightGreen: '#7bb137', # UGJ
          brown: '#7b352a', # BJ
          green: '#237333', # SWB
          lavender: '#baa4cb', # SNJ
          olive: '#808000', # TGOJ (not right)
          orange: '#f48221', # MOJ
          red: '#d81e3e', # OSJ
          violet: '#4d2674', # OKJ
          white: '#ffffff', # KFJr
          yellow: '#FFF500' # MYJ
        )

        CURRENCY_FORMAT_STR = '%d kr'

        BANK_CASH = 10_000

        CERT_LIMIT = { 2 => 28, 3 => 20, 4 => 16, 5 => 13, 6 => 11 }.freeze

        STARTING_CASH = { 2 => 1200, 3 => 800, 4 => 600, 5 => 480, 6 => 400 }.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false

        MARKET_TEXT = Base::MARKET_TEXT.merge(
          endgame: 'Game end at end of current operating round',
          max_price: 'Double jump if double revenue if stock price is at least 90 kr',
          multiple_buy: 'Can buy more than one share in the corporation per turn, redeem all shares at no cost',
          no_cert_limit: 'Corporation shares do not count towards cert limit, redeem one shares at half cost (rounded down)',
          par: 'Available par values',
          unlimited: 'Corporation shares can be held above 60%, redeem all shares at half cost (rounded down)',
        ).freeze

        # New track must be usable, or upgrade city value
        TRACK_RESTRICTION = :semi_restrictive

        TILES = {
          '5' => 4,
          '6' => 4,
          '7' => 20,
          '8' => 20,
          '9' => 20,
          '14' => 4,
          '15' => 4,
          '16' => 2,
          '17' => 1,
          '18' => 1,
          '19' => 2,
          '20' => 2,
          '21' => 1,
          '22' => 1,
          '23' => 3,
          '24' => 3,
          '25' => 2,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '57' => 5,
          '63' => 2,
          '70' => 1,
          '131' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:90,slots:4;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          '172' => 2,
          '298SJ' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,groups:Stockholm;city=revenue:40,groups:Stockholm;'\
                      'city=revenue:40,groups:Stockholm;city=revenue:40,groups:Stockholm;path=a:0,b:_0;path=a:_0,b:2;'\
                      'path=a:3,b:_1;path=a:_1,b:2;path=a:4,b:_2;path=a:_2,b:2;path=a:5,b:_3;path=a:_3,b:2',
          },
          '299SJ' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,groups:Stockholm;city=revenue:70,groups:Stockholm;'\
                      'city=revenue:70,groups:Stockholm;city=revenue:70,groups:Stockholm;path=a:0,b:_0;path=a:_0,b:2;'\
                      'path=a:3,b:_1;path=a:_1,b:2;path=a:4,b:_2;path=a:_2,b:2;path=a:5,b:_3;path=a:_3,b:2',
          },
          '440' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Y',
          },
          '466' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Y',
          },
          '611' => 2,
          '619' => 3,
        }.freeze

        LOCATION_NAMES = {
          'A2' => 'Malmö',
          'A6' => 'Halmstad',
          'A10' => 'Göteborg',
          'A16' => 'Oslo',
          'B5' => 'Hässleholm',
          'B11' => 'Alingsås',
          'B31' => 'Narvik',
          'C2' => 'Ystad',
          'C8' => 'Jönköping',
          'C12' => 'Skövde',
          'C16' => 'Karlstad',
          'C24' => 'Östersund',
          'D5' => 'Kalmar',
          'D11' => 'Katrineholm',
          'D15' => 'Köping',
          'D19' => 'Bergslagen',
          'D21' => 'Sveg',
          'D29' => 'Malmfälten',
          'E8' => 'Norrköping',
          'E12' => 'Västerås',
          'E20' => 'Ånge',
          'F13' => 'Uppsala',
          'F19' => 'Sundsvall',
          'F23' => 'Umeå',
          'G10' => 'Stockholm',
          'G26' => 'Luleå',
          'H9' => 'Stockholms hamn',
        }.freeze

        MARKET = [
          %w[82m 90 100p 110 125 140 160 180 200 225 250 275 300 325 350 375e 400e],
          %w[76 82m 90p 100 110 125 140 160 180 200 220 240 260 280 300],
          %w[71 76 82pm 90 100 111 125 140 155 170 185 200],
          %w[67 71 76p 82m 90 100 110 120 140],
          %w[65 67 71p 76 82m 90 100],
          %w[63y 65 67p 71 76 82],
          %w[60y 63y 65 67 71],
          %w[50o 60y 63y 65],
          %w[40b 50o 60y],
          %w[30b 40b 50o],
          %w[20b 30b 40b],
        ].freeze

        PHASES = [
          {
            name: '2',
            on: '2',
            train_limit: 4,
            tiles: %i[yellow],
            operating_rounds: 1,
            status: %w[incremental],
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[incremental can_buy_companies],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[incremental can_buy_companies],
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[fullcap],
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
            status: %w[fullcap],
          },
          {
            name: 'D',
            on: 'D',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
            status: %w[fullcap],
          },
          {
            name: 'E',
            on: 'E',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
            status: %w[fullcap],
          },
        ].freeze

        TRAINS = [{ name: '2', distance: 2, price: 80, rusts_on: '4', num: 7 },
                  { name: '3', distance: 3, price: 180, rusts_on: '6', num: 5 },
                  {
                    name: '4',
                    distance: 4,
                    price: 300,
                    rusts_on: 'D',
                    num: 4,
                    events: [{ 'type' => 'nationalization' }],
                  },
                  {
                    name: '5',
                    distance: 5,
                    price: 530,
                    num: 3,
                    events: [{ 'type' => 'close_companies' }, { 'type' => 'full_cap' }],
                  },
                  {
                    name: '6',
                    distance: 6,
                    price: 630,
                    num: 2,
                    events: [{ 'type' => 'nationalization' }],
                  },
                  {
                    name: 'D',
                    distance: 999,
                    price: 1100,
                    num: 20,
                    available_on: '6',
                    discount: { '4' => 300, '5' => 300, '6' => 300 },
                    variants: [{ name: 'E', price: 1300 }],
                    events: [{ 'type' => 'nationalization' }],
                  }].freeze

        COMPANIES = [
          {
            name: 'Frykstadsbanan',
            value: 20,
            revenue: 5,
            desc: 'Blocks hex B17 if owned by a player.',
            sym: 'FRY',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['B17'] }],
          },
          {
            name: 'Nässjö-Oskarshamns järnväg',
            value: 20,
            revenue: 5,
            desc: 'Blocks hex D9 if owned by a player.',
            sym: 'NOJ',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['D9'] }],
          },
          {
            name: 'Göta kanalbolag',
            value: 40,
            revenue: 10,
            desc: 'Owning corporation may add a hex bonus to each train visit to any of the hexes E8, C8 and C16 '\
                  'in three different ORs. Each train can receive the bonus multiple times. The bonus are 50kr the first '\
                  'time this ability is used, 30kr the second and 20kr the third and last time. Using this ability '\
                  'will not close the prive.',
            sym: 'GKB',
            abilities:
            [
              {
                type: 'hex_bonus',
                owner_type: 'corporation',
                hexes: %w[C8 C16 E8],
                count: 3,
                amount: 50,
                when: 'route',
              },
            ],
          },
          {
            name: 'Sveabolaget',
            value: 45,
            revenue: 15,
            desc: 'May lay or shift port token in Halmstad (A6), Ystad(C2), Kalmar (D5), Sundsvall (F19), Umeå (F23), '\
                  'and Luleå (G26).  Add 30 kr/symbol to all routes run to this location by owning company.',
            sym: 'SB',
            abilities:
            [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: %w[A6 C2 D5 F19 F23 G26],
                owner_type: 'corporation',
              },
            ],
          },
          {
            name: 'The Gellivare Company',
            value: 70,
            revenue: 15,
            desc: 'Two extra track lays in hex E28 and F27.  Blocks hexes E28 and F27 if owned by a player. '\
                  'Reduce terrain cost in D29 and C30 to 25 kr for mountains and 50 kr for the Narvik border.',
            sym: 'GC',
            abilities:
            [
              { type: 'blocks_hexes', owner_type: 'player', hexes: %w[E28 F27] },
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                hexes: %w[E28 F27],
                tiles: %w[7 8 9],
                when: %w[track owning_corp_or_turn],
                count: 2,
              },
              {
                type: 'tile_discount',
                discount: 50,
                terrain: 'mountain',
                owner_type: 'corporation',
                hexes: %w[C30 D29],
              },
              {
                type: 'tile_discount',
                discount: 100,
                terrain: 'water',
                owner_type: 'corporation',
                hexes: %w[C30],
              },
            ],
          },
          {
            name: 'Motala Verkstad',
            value: 90,
            revenue: 15,
            desc: 'Owning corporation may do a premature buy of one or more trains, just before Run Routes. '\
                  'These trains can be run even if they have run earlier in the OR. If ability is used the owning '\
                  'corporation cannot buy any trains later in the same OR.',
            sym: 'MV',
            abilities:
            [
              {
                type: 'train_buy',
                description: 'Buy trains before instead of after Run Routes',
                owner_type: 'corporation',
              },
            ],
          },
          {
            name: 'Nydqvist och Holm AB',
            value: 90,
            revenue: 20,
            desc: 'May buy one train at half price (one time during the game).',
            sym: 'NOHAB',
            abilities:
            [
              {
                type: 'train_discount',
                discount: 0.5,
                owner_type: 'corporation',
                trains: %w[3 4 5],
                count: 1,
                when: 'buying_train',
              },
            ],
          },
          {
            name: 'Köping-Hults järnväg',
            value: 140,
            revenue: 0,
            desc: 'Buy gives control to minor corporation with same name. The minor starts with a 2 train '\
                  'and a home token and splits revenue evenly with owner. The minor may never buy or sell trains.',
            sym: 'KHJ',
          },
          {
            name: 'Nils Ericson',
            value: 220,
            revenue: 25,
            desc: "Receive president's share in a corporation randomly determined before auction. "\
                  'Buying player may once during the game take the priority deal at the beginning of one stock round '\
                  '(and this ability is not lost even if this private is closed). Cannot be bought by any corporation. '\
                  'Closes when the connected corporation buys its first train.',
            sym: 'NE',
            abilities: [{ type: 'shares', shares: 'random_president' }, { type: 'no_buy' }],
          },
          {
            name: 'Nils Ericson Första Tjing',
            value: 0,
            revenue: 0,
            desc: 'This represents the ability to once during the game take over the priority deal at the beginning '\
                  "of a stock round. Cannot be bought by any corporation. This 'company' remains through the whole game, "\
                  'or until the ability is used.',
            sym: 'NEFT',
            abilities: [{ type: 'no_buy' }, { type: 'close', on_phase: 'never', owner_type: 'player' }],
          },
          {
            name: 'Adolf Eugene von Rosen',
            value: 220,
            revenue: 30,
            desc: "Receive president's share in ÖKJ. Cannot be bought by any corporation. Closes when ÖKJ "\
                  'buys its first train.',
            sym: 'AEvR',
            abilities: [{ type: 'shares', shares: 'ÖKJ_0' },
                        { type: 'close', when: 'bought_train', corporation: 'ÖKJ' },
                        { type: 'no_buy' }],
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'BJ',
            name: 'Bergslagernas järnvägar AB',
            logo: '18_sj/BJ',
            simple_logo: '18_sj/BJ.alt',
            tokens: [0, 40, 100],
            coordinates: 'A10',
            color: '#7b352a',
            always_market_price: true,
          },
          {
            float_percent: 60,
            sym: 'KFJ',
            name: 'Kil-Fryksdalens Järnväg',
            logo: '18_sj/KFJ',
            simple_logo: '18_sj/KFJ.alt',
            tokens: [0, 40, 100],
            coordinates: 'C16',
            color: :pink,
            text_color: 'black',
            always_market_price: true,
          },
          {
            float_percent: 60,
            sym: 'MYJ',
            name: 'Malmö-Ystads järnväg',
            logo: '18_sj/MYJ',
            simple_logo: '18_sj/MYJ.alt',
            tokens: [0, 40, 100],
            coordinates: 'A2',
            color: '#FFF500',
            text_color: 'black',
            always_market_price: true,
          },
          {
            float_percent: 60,
            sym: 'MÖJ',
            name: 'Mellersta Östergötlands Järnvägar',
            logo: '18_sj/MOJ',
            simple_logo: '18_sj/MOJ.alt',
            tokens: [0, 40],
            coordinates: 'E8',
            color: :turquoise,
            text_color: 'black',
            always_market_price: true,
          },
          {
            float_percent: 60,
            sym: 'SNJ',
            name: 'The Swedish-Norwegian Railroad Company ltd',
            logo: '18_sj/SNJ',
            simple_logo: '18_sj/SNJ.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'G26',
            color: :blue,
            always_market_price: true,
          },
          {
            float_percent: 60,
            sym: 'STJ',
            name: 'Sundsvall-Torphammars järnväg',
            logo: '18_sj/STJ',
            simple_logo: '18_sj/STJ.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'F19',
            color: '#0a0a0a',
            always_market_price: true,
          },
          {
            float_percent: 60,
            sym: 'SWB',
            name: 'Stockholm-Västerås-Bergslagens Järnvägar',
            logo: '18_sj/SWB',
            simple_logo: '18_sj/SWB.alt',
            tokens: [0, 40],
            coordinates: 'G10',
            city: 2,
            color: '#237333',
            always_market_price: true,
          },
          {
            float_percent: 60,
            sym: 'TGOJ',
            name: 'Trafikaktiebolaget Grängesberg-Oxelösunds järnvägar',
            logo: '18_sj/TGOJ',
            simple_logo: '18_sj/TGOJ.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'D19',
            color: '#f48221',
            always_market_price: true,
          },
          {
            float_percent: 60,
            sym: 'UGJ',
            name: 'Uppsala-Gävle järnväg',
            logo: '18_sj/UGJ',
            simple_logo: '18_sj/UGJ.alt',
            tokens: [0, 40, 100],
            coordinates: 'F13',
            color: :lime,
            text_color: 'black',
            always_market_price: true,
          },
          {
            float_percent: 60,
            sym: 'ÖKJ',
            name: 'Örebro-Köpings järnvägsaktiebolag',
            logo: '18_sj/OKJ',
            simple_logo: '18_sj/OKJ.alt',
            tokens: [0, 40],
            coordinates: 'C12',
            color: :purple,
            always_market_price: true,
          },
          {
            float_percent: 60,
            sym: 'ÖSJ',
            name: 'Östra Skånes Järnvägsaktiebolag',
            logo: '18_sj/OSJ',
            simple_logo: '18_sj/OSJ.alt',
            tokens: [0, 40, 100],
            coordinates: 'C2',
            color: '#d81e3e',
            always_market_price: true,
          },
        ].freeze

        MINORS = [
          {
            sym: 'KHJ',
            name: 'Köping-Hults järnväg',
            logo: '18_sj/KHJ',
            simple_logo: '18_sj/KHJ.alt',
            tokens: [0],
            coordinates: 'D15',
            color: '#ffffff',
            text_color: 'black',
          },
        ].freeze

        HEXES = {
          red: {
            ['A2'] => 'city=revenue:yellow_20|green_40|brown_50;path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1;'\
                      'icon=image:18_sj/V,sticky:1;icon=image:18_sj/b_lower_case,sticky:1',
            ['A10'] => 'city=revenue:yellow_20|green_40|brown_70;path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1;'\
                       'path=a:0,b:_0,terminal:1;icon=image:18_sj/V,sticky:1;icon=image:18_sj/b_lower_case,sticky:1',
            ['B31'] => 'offboard=revenue:yellow_20|green_30|brown_70;path=a:0,b:_0;icon=image:18_sj/N,sticky:1;'\
                       'icon=image:18_sj/m_lower_case,sticky:1;border=edge:0,type:water,cost:150',
            ['H9'] => 'offboard=revenue:green_30|brown_40;path=a:3,b:_0;icon=image:18_sj/O,sticky:1;'\
                      'icon=image:18_sj/b_lower_case,sticky:1;label=S;icon=image:18_sj/S,sticky:1',
          },
          gray: {
            ['A6'] => 'city=revenue:20;path=a:5,b:_0;path=a:0,b:_0;icon=image:port;icon=image:port',
            ['A16'] => 'city=revenue:yellow_50|green_40|brown_20;path=a:1,b:_0;path=a:5,b:_0;path=a:0,b:_0',
            ['D5'] => 'city=revenue:20;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;icon=image:port',
            ['F19'] => 'city=revenue:20;path=a:2,b:_0;path=a:3,b:_0;icon=image:port',
            ['F23'] => 'city=revenue:20;path=a:2,b:_0;path=a:3,b:_0;icon=image:port;icon=image:port',
            ['G26'] => 'city=revenue:20,slots:2;path=a:2,b:_0;path=a:3,b:_0;icon=image:port;'\
                       'icon=image:18_sj/m_lower_case,sticky:1',
          },
          blue: {
            ['B1'] => 'path=a:4,b:5',
            ['G8'] => 'path=a:3,b:4',
            %w[B13 C14] => '',
          },
          white: {
            %w[A4 C6 D7] => 'icon=image:18_sj/M-S,sticky:1',
            ['D13'] => 'icon=image:18_sj/G-S,sticky:1',
            %w[E14 E16 E18 E24 F25 G12] =>
              'icon=image:18_sj/L-S,sticky:1',
            ['E22'] => 'upgrade=cost:75,terrain:mountain;icon=image:18_sj/L-S,sticky:1',
            ['B5'] => 'city=revenue:0;icon=image:18_sj/M-S,sticky:1',
            ['E8'] =>
              'city=revenue:0;icon=image:18_sj/M-S,sticky:1;icon=image:18_sj/GKB,sticky:1',
            ['E12'] => 'city=revenue:0;icon=image:18_sj/G-S,sticky:1',
            %w[F13 E20] => 'city=revenue:0;icon=image:18_sj/L-S,sticky:1',
            ['C12'] =>
              'city=revenue:0;border=edge:2,type:mountain,cost:75;icon=image:18_sj/G-S,sticky:1',
            ['B11'] =>
              'city=revenue:0;border=edge:5,type:mountain,cost:75;icon=image:18_sj/G-S,sticky:1',
            %w[A12 B19 B21 B23 B25 B27 B29] =>
              'upgrade=cost:75,terrain:mountain',
            ['C30'] =>
              'upgrade=cost:75,terrain:mountain;border=edge:3,type:water,cost:150',
            ['D9'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable',
            %w[B17 A8 A14 B3 B7 B9 B15 C4 C18 C20 C22 C26 C28 D17 D23 D25 D27 D31] => '',
            %w[E10 E26 E28 E30 F15 F17 F21 F29 G14 G28 F27] => '',
            ['C10'] => 'border=edge:0,type:impassable;border=edge:5,type:impassable',
            %w[C24 D21] => 'city=revenue:0',
            ['C16'] => 'city=revenue:0;icon=image:18_sj/GKB,sticky:1',
            ['D11'] => 'city=revenue:0;border=edge:2,type:impassable',
            ['D29'] =>
              'city=revenue:0;upgrade=cost:75,terrain:mountain;icon=image:18_sj/M,sticky:1',
            ['F9'] => 'upgrade=cost:150,terrain:mountain;icon=image:18_sj/M-S,sticky:1',
            ['F11'] => 'upgrade=cost:75,terrain:mountain;icon=image:18_sj/G-S,sticky:1',
          },
          yellow: {
            ['C2'] => 'city=revenue:20;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Y;icon=image:port,sticky:1',
            ['C8'] =>
              'city=revenue:20;path=a:1,b:_0;path=a:2,b:_0;border=edge:5,type:impassable;icon=image:18_sj/GKB,sticky:1',
            ['D15'] => 'city=revenue:20;path=a:1,b:_0;path=a:5,b:_0',
            ['D19'] =>
              'city=revenue:20;path=a:5,b:_0;path=a:0,b:_0;icon=image:18_sj/B,sticky:1',
            ['G10'] =>
              'city=revenue:20,groups:Stockholm;city=revenue:20,groups:Stockholm;'\
              'city=revenue:20,groups:Stockholm;city=revenue:20,groups:Stockholm;path=a:1,b:_0;path=a:2,b:_1;'\
              'path=a:3,b:_2;path=a:4,b:_3',
          },
        }.freeze

        LAYOUT = :pointy

        # Stock market 350 triggers end of game in same OR, but bank full OR set
        GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_or, bank: :full_or }.freeze

        SELL_BUY_ORDER = :sell_buy_sell

        # At most a corporation/minor can do two tile lay / upgrades but two is
        # only allowed if one improves main line situation. This means a 2nd
        # tile lay/upgrade might not be allowed.
        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, upgrade: true }].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'full_cap' => ['Full Capitalization',
                         'Unsold corporations becomes Full Capitalization and move shares to IPO'],
          'nationalization' => ['Nationalization check', 'The topmost corporation without trains are nationalized'],
        ).freeze

        STATUS_TEXT = {
          'incremental' => [
            'Incremental Cap',
            'New corporations will be capitalized for all 10 shares as they are sold',
          ],
          'fullcap' => [
            'Full Cap',
            'New corporations will be capitalized for 10 x par price when 60% of the IPO is sold',
          ],
        }.merge(Base::STATUS_TEXT).freeze

        OPTIONAL_PRIVATE_A = %w[NE AEvR].freeze
        OPTIONAL_PRIVATE_B = %w[NOJ FRY].freeze
        OPTIONAL_PRIVATE_C = %w[NOHAB MV].freeze
        OPTIONAL_PRIVATE_D = %w[GKB SB].freeze
        OPTIONAL_PUBLIC = %w[STJ TGOJ ÖSJ MYJ].freeze

        MAIN_LINE_ORIENTATION = {
          # Stockholm-Malmo main line
          'F9' => [2, 5],
          'E8' => [2, 5],
          'D7' => [2, 5],
          'C6' => [2, 5],
          'B5' => [2, 5],
          'A4' => [1, 5],
          # Stockholm-Goteborg main line
          'F11' => [0, 3],
          'E12' => [0, 3],
          'D13' => [0, 2],
          'C12' => [2, 5],
          'B11' => [2, 5],
          # Stockholm-Lulea main line
          'G12' => [1, 3],
          'F13' => [0, 3],
          'E14' => [0, 4],
          'E16' => [1, 4],
          'E18' => [1, 4],
          'E20' => [1, 4],
          'E22' => [1, 4],
          'E24' => [1, 5],
          'F25' => [2, 5],
        }.freeze

        MAIN_LINE_COUNT = {
          'M-S' => 6,
          'G-S' => 5,
          'L-S' => 9,
        }.freeze

        MAIN_LINE_DESCRIPTION = {
          'M-S' => 'Stockholm-Malmö',
          'G-S' => 'Stockholm-Göteborg',
          'L-S' => 'Stochholm-Luleå',
        }.freeze

        MAIN_LINE_ICONS = %w[M-S G-S L-S].freeze

        BONUS_ICONS = %w[N S O V M m_lower_case B b_lower_case].freeze

        ASSIGNMENT_TOKENS = {
          'SB' => '/icons/18_sj/sb_token.svg',
        }.freeze

        GKB_HEXES = %w[C8 C16 E8].freeze

        def oscarian_era
          @optional_rules&.include?(:oscarian_era)
        end

        def init_corporations(stock_market)
          corporations = super
          removed_corporation = select(OPTIONAL_PUBLIC)
          to_close = corporations.find { |corp| corp.name == removed_corporation }
          corporations.delete(to_close)
          @log << "Removed corporation: #{to_close.full_name} (#{to_close.name})"

          return corporations unless oscarian_era

          # Make all corporations full cap
          corporations.map do |c|
            c.capitalization = :full
            c
          end
        end

        def init_companies(players)
          companies = super
          @removed_companies = []
          [OPTIONAL_PRIVATE_A, OPTIONAL_PRIVATE_B, OPTIONAL_PRIVATE_C, OPTIONAL_PRIVATE_D].each do |optionals|
            to_remove = find_company(companies, optionals)
            to_remove.close!
            # companies.delete(to_remove)
            @removed_companies << to_remove
          end
          @log << "Removed companies: #{@removed_companies.map(&:name).join(', ')}"

          # Handle Priority Deal Chooser private (NEFT)
          # It is removed if Nils Ericsson is removed (as it does not appear among the buyable ones).
          # If Nils Ericsson remains, put NEFT last and let bank be owner, so it wont disturb auction,
          # and it will be assigned to NE owner in the auction.
          pdc = companies.find { |c| c.sym == 'NEFT' }
          if @removed_companies.find { |c| c.sym == 'NE' }
            @removed_companies << pdc
          else
            pdc.owner = @bank
          end

          companies - @removed_companies
        end

        def game_phases
          return self.class::PHASES unless oscarian_era

          self.class::PHASES.map do |p|
            p[:status] -= ['fullcap']
            p
          end
        end

        def select(collection)
          collection[rand % collection.size]
        end

        def find_company(companies, collection)
          sym = collection[rand % collection.size]
          to_find = companies.find { |comp| comp.sym == sym }
          @log << "Could not find company with sym='#{sym}' in #{@companies}" unless to_find
          to_find
        end

        def minor_khj
          @minor_khj ||= minor_by_id('KHJ')
        end

        def company_khj
          @company_khj ||= company_by_id('KHJ')
        end

        def nils_ericsson
          @nils_ericsson ||= company_by_id('NE')
        end

        def priority_deal_chooser
          @priority_deal_chooser ||= company_by_id('NEFT')
        end

        def sveabolaget
          @sveabolaget ||= company_by_id('SB')
        end

        def motala_verkstad
          @motala_verkstad ||= company_by_id('MV')
        end

        def gkb
          @gkb ||= company_by_id('GKB')
        end

        def gc
          @gc ||= company_by_id('GC')
        end

        def ipo_name(entity)
          entity&.capitalization == :incremental ? 'Treasury' : 'IPO'
        end

        def setup
          # Possibly remove from map icons belonging to closed companies
          @removed_companies.each { |c| close_cleanup(c) }

          @minors.each do |minor|
            train = @depot.upcoming[0]
            train.buyable = false
            buy_train(minor, train, :free)
            hex = hex_by_id(minor.coordinates)
            hex.tile.cities[0].place_token(minor, minor.next_token)
          end

          if nils_ericsson && !nils_ericsson.closed?
            nils_ericsson.add_ability(Ability::Close.new(
              type: :close,
              when: 'bought_train',
              corporation: abilities(nils_ericsson, :shares).shares.first.corporation.name,
            ))
          end

          @special_tile_lays = []

          @main_line_built = {
            'M-S' => 0,
            'G-S' => 0,
            'L-S' => 0,
          }

          # Create virtual SJ corporation
          @sj = Corporation.new(
            sym: 'SJ',
            name: 'Statens Järnvägar',
            logo: '18_sj/SJ',
            simple_logo: '18_sj/SJ.alt',
            tokens: [],
          )
          @sj.owner = @bank

          @pending_nationalization = false

          @sj_tokens_passable = false

          @stockholm_tile_gray ||= @tiles.find { |t| t.name == '131' }

          return unless oscarian_era

          # Remove full cap event as all corporations are full cap
          @depot.trains.each do |t|
            t.events = t.events.reject { |e| e[:type] == 'full_cap' }
          end
        end

        def cert_limit
          current_cert_limit
        end

        def num_certs(entity)
          count = super
          count -= 1 if priority_deal_chooser&.owner == entity
          count
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            G18SJ::Step::WaterfallAuction,
          ])
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G18SJ::Step::ChoosePriority,
            G18SJ::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          G18SJ::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::DiscardTrain,
            G18SJ::Step::Assign,
            G18SJ::Step::SpecialTrack,
            G18SJ::Step::BuyCompany,
            G18SJ::Step::IssueShares,
            Engine::Step::HomeToken,
            G18SJ::Step::Track,
            Engine::Step::Token,
            G18SJ::Step::BuyTrainBeforeRunRoute,
            G18SJ::Step::Route,
            G18SJ::Step::Dividend,
            G18SJ::Step::SpecialBuyTrain,
            G18SJ::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        # Check if tile lay action improves a main line hex
        # If it does return the main line name
        # If not remove nil
        # Side effect: Remove the main line icon from the hex if improvement is done
        def main_line_improvement(action)
          main_line_icon = action.hex.tile.icons.find { |i| MAIN_LINE_ICONS.include?(i.name) }
          return if !main_line_icon || !connects_main_line?(action.hex)

          main_line_icon_name = main_line_icon.name
          @log << "Main line #{MAIN_LINE_DESCRIPTION[main_line_icon_name]} was "\
                  "#{main_line_completed?(main_line_icon_name) ? 'completed!' : 'improved'}"
          remove_icon(action.hex, [main_line_icon_name])
        end

        def special_tile_lay(action)
          @special_tile_lays << action
        end

        def redeemable_shares(entity)
          return [] unless entity.corporation?
          return [] unless round.steps.find { |step| step.instance_of?(G18SJ::Step::IssueShares) }.active?

          type = entity.share_price.type

          share_price = stock_market.find_share_price(entity, :right).price
          share_price = 0 if brown?(type)
          share_price /= 2 if orange?(type) || yellow?(type)

          bundle_max_size = 1
          bundle_max_size = 10 if orange?(type) || yellow?(type)

          bundles_for_corporation(share_pool, entity)
            .each { |bundle| bundle.share_price = share_price }
            .reject { |bundle| bundle.shares.size > bundle_max_size }
            .reject { |bundle| entity.cash < bundle.price }
        end

        def orange?(type)
          type == :unlimited
        end

        def yellow?(type)
          type == :no_cert_limit
        end

        def brown?(type)
          type == :multiple_buy
        end

        def revenue_for(route, stops)
          revenue = super

          icons = visited_icons(stops)

          [lapplandspilen_bonus(icons),
           east_west_bonus(icons, stops),
           bergslagen_bonus(icons),
           orefields_bonus(icons),
           sveabolaget_bonus(route),
           gkb_bonus(route)].map { |b| b[:revenue] }.each { |r| revenue += r }

          return revenue unless route.train.name == 'E'

          # E trains double any city revenue if corporation's token (or SJ) is present
          revenue + stops.sum do |stop|
            friendly_city?(route, stop) ? stop.route_revenue(route.phase, route.train) : 0
          end
        end

        def revenue_str(route)
          stops = route.stops
          stop_hexes = stops.map(&:hex)
          str = route.hexes.map do |h|
            stop_hexes.include?(h) ? h&.name : "(#{h&.name})"
          end.join('-')

          icons = visited_icons(stops)

          [lapplandspilen_bonus(icons),
           east_west_bonus(icons, stops),
           bergslagen_bonus(icons),
           orefields_bonus(icons),
           sveabolaget_bonus(route),
           gkb_bonus(route)].map { |b| b[:description] }.compact.each { |d| str += " + #{d}" }

          str
        end

        def clean_up_after_dividend
          # Remove Gellivare Company tile lay ability if it has been used this OR
          unless @special_tile_lays.empty?
            abilities(gc, :tile_lay) do |ability|
              gc.remove_ability(ability)
              @log << "#{gc.name} tile lay ability removed"
            end
          end
          @special_tile_lays = []

          make_sj_tokens_impassable
        end

        # Make SJ passable if current corporation has E train
        # This is a workaround that is not perfect in case a
        # corporation has E train + other train, but very unlikely
        def make_sj_tokens_passable_for_electric_trains(entity)
          return unless owns_electric_train?(entity)

          @sj.tokens.each { |t| t.type = :neutral }
          @sj_tokens_passable = true
        end

        def make_sj_tokens_impassable
          return unless @sj_tokens_passable

          @sj.tokens.each { |t| t.type = :blocking }
          @sj_tokens_passable = false
        end

        def event_close_companies!
          @companies.each { |c| close_cleanup(c) }
          super

          return if minor_khj.closed?

          @log << "Minor #{minor_khj.name} closes and its home token is removed"
          minor_khj.spend(minor_khj.cash, @bank) if minor_khj.cash.positive?
          minor_khj.tokens.first.remove!
          minor_khj.close!
        end

        def event_full_cap!
          @corporations
            .select { |c| c.percent_of(c) == 100 && !c.closed? }
            .each do |c|
              @log << "#{c.name} becomes full capitalization corporation as it has not been parred"
              c.capitalization = :full
            end
        end

        def event_nationalization!
          @pending_nationalization = true
        end

        def pending_nationalization?
          @pending_nationalization
        end

        def perform_nationalization
          @pending_nationalization = false
          candidates = @corporations.select { |c| !c.closed? && c.operated? && c.trains.empty? }
          if candidates.empty?
            @log << 'Nationalization skipped as no trainless floated corporations'
            return
          end

          # Merge the corporation with highest share price, and use the first operated as tie break
          merged = candidates.max_by { |c| [c.share_price.price, -@round.entities.find_index(c)] }

          nationalize_major(merged)
        end

        # If there are 2 station markers on the same city the
        # merged corporation must remove one and return it to its charter.
        # Return number of duplications.
        def remove_duplicate_tokens(target, merged)
          merged_tokens = merged.tokens.map(&:city).compact
          duplicate_count = 0
          target.tokens.each do |token|
            city = token.city
            if merged_tokens.include?(city)
              token.remove!
              duplicate_count += 1
            end
          end
          duplicate_count
        end

        def remove_reservation(merged)
          hex = hex_by_id(merged.coordinates)
          tile = hex.tile
          cities = tile.cities
          city = cities.find { |c| c.reserved_by?(merged) } || cities.first
          city.remove_reservation!(merged)
        end

        def transfer_home_token(target, merged)
          merged_home_token = merged.tokens.first
          return unless merged_home_token.city

          transfer_token(merged_home_token, merged, target)
        end

        def transfer_non_home_tokens(target, merged)
          merged.tokens.each do |token|
            next unless token.city

            transfer_token(token, merged, target)
          end
        end

        def entity_can_use_company?(entity, company)
          return false if company == nydqvist_och_holm && company.owner != entity

          super
        end

        def upgrades_to?(from, to, _special = false, selected_company: nil)
          # Handle upgrade to Stockholm gray tile
          return to.name == '131' if from.color == :brown && from.hex.name == 'G10'
          return false if to.name == '131'

          super
        end

        def all_potential_upgrades(tile, tile_manifest: false, selected_company: nil)
          upgrades = super

          return upgrades unless tile_manifest

          # Handle Stockholm tile manifest
          upgrades |= [@stockholm_tile_gray] if @stockholm_tile_gray && tile.name == '299SJ'

          upgrades
        end

        private

        def main_line_hex?(hex)
          MAIN_LINE_ORIENTATION[hex.name]
        end

        def connects_main_line?(hex)
          return unless (orientation = MAIN_LINE_ORIENTATION[hex.name])

          paths = hex.tile.paths
          exits = [orientation[0], orientation[1]]
          paths.any? { |path| (path.exits & exits).size == 2 } ||
            (path_to_city(paths, orientation[0]) && path_to_city(paths, orientation[1]))
        end

        def path_to_city(paths, edge)
          paths.find { |p| p.exits == [edge] }
        end

        def main_line_completed?(main_line_icon_name)
          @main_line_built[main_line_icon_name] += 1
          @main_line_built[main_line_icon_name] == MAIN_LINE_COUNT[main_line_icon_name]
        end

        CERT_LIMITS = {
          10 => { 2 => 39, 3 => 26, 4 => 20, 5 => 16, 6 => 13 },
          9 => { 2 => 35, 3 => 23, 4 => 18, 5 => 14, 6 => 12 },
          8 => { 2 => 30, 3 => 20, 4 => 15, 5 => 12, 6 => 10 },
          7 => { 2 => 26, 3 => 17, 4 => 13, 5 => 11, 6 => 9 },
        }.freeze

        def current_cert_limit
          available_corporations = @corporations.count { |c| !c.closed? }
          available_corporations = 10 if available_corporations > 10

          certs_per_player = CERT_LIMITS[available_corporations]
          raise GameError, "No cert limit defined for #{available_corporations} corporations" unless certs_per_player

          set_cert_limit = certs_per_player[@players.size]
          raise GameError, "No cert limit defined for #{@players.size} players" unless set_cert_limit

          set_cert_limit
        end

        def nationalize_major(major)
          @log << "#{major.name} is nationalized"

          remove_reservation(major)
          transfer_home_token(@sj, major)
          transfer_non_home_tokens(@sj, major)

          major.companies.dup.each(&:close!)

          # Decrease share price two step and then give compensation with this price
          prev = major.share_price.price
          @stock_market.move_left(major)
          @stock_market.move_left(major)
          log_share_price(major, prev)
          refund = major.share_price.price
          @players.each do |p|
            refund_amount = 0
            p.shares_of(major).dup.each do |s|
              next unless s

              refund_amount += (s.percent / 10) * refund
              s.transfer(major)
            end
            next unless refund_amount.positive?

            @log << "#{p.name} receives #{format_currency(refund_amount)} in share compensation"
            @bank.spend(refund_amount, p)
          end

          # Transfer bank pool shares to IPO
          @share_pool.shares_of(major).dup.each do |s|
            s.transfer(major)
          end

          major.spend(major.cash, @bank) if major.cash.positive?
          major.close!
          @log << "#{major.name} closes and its tokens becomes #{@sj.name} tokens"

          # Cert limit changes as the number of corporations decrease
          @log << "Certificate limit is now #{cert_limit}"
        end

        def transfer_token(token, merged, target_corporation)
          city = token.city

          if tokened_hex_by(city.hex, target_corporation)
            @log << "#{merged.name}'s token in #{token.city.hex.name} is removed "\
                    "as there is already a #{target_corporation.name} token there"
            token.remove!
          else
            @log << "#{merged.name}'s token in #{city.hex.name} is replaced with an #{target_corporation.name} token"
            token.remove!
            replacement_token = Engine::Token.new(target_corporation)
            target_corporation.tokens << replacement_token
            city.place_token(target_corporation, replacement_token, check_tokenable: false)
          end
        end

        def visited_icons(stops)
          icons = []
          stops.each do |s|
            s.hex.tile.icons.each do |icon|
              next unless BONUS_ICONS.include?(icon.name)

              icons << icon.name
            end
          end
          icons.sort!
        end

        def lapplandspilen_bonus(icons)
          bonus = { revenue: 0 }

          if icons.include?('N') && icons.include?('S')
            bonus[:revenue] += 100
            bonus[:description] = 'N/S'
          end

          bonus
        end

        def east_west_bonus(icons, stops)
          bonus = { revenue: 0 }
          hexes = stops.map { |s| s.hex.id }

          if icons.include?('O') && icons.include?('V') && hexes.include?('H9') && (hexes.include?('A2') || hexes.include?('A10'))
            bonus[:revenue] += 120
            bonus[:description] = 'Ö/V'
          end

          bonus
        end

        def bergslagen_bonus(icons)
          bonus = { revenue: 0 }

          if icons.include?('B') && icons.count('b_lower_case') == 1
            bonus[:revenue] += 50
            bonus[:description] = 'b/B'
          end
          if icons.include?('B') && icons.count('b_lower_case') > 1
            bonus[:revenue] += 100
            bonus[:description] = 'b/B/b'
          end

          bonus
        end

        def orefields_bonus(icons)
          bonus = { revenue: 0 }

          if icons.include?('M') && icons.count('m_lower_case') == 1
            bonus[:revenue] += 50
            bonus[:description] = 'm/M'
          end
          if icons.include?('M') && icons.count('m_lower_case') > 1
            bonus[:revenue] += 100
            bonus[:description] = 'm/M/m'
          end

          bonus
        end

        def sveabolaget_bonus(route)
          bonus = { revenue: 0 }

          steam = sveabolaget&.id
          revenue = 0
          if route.corporation == sveabolaget&.owner &&
            (port = route.stops.map(&:hex).find { |hex| hex.assigned?(steam) })
            revenue += 30 * port.tile.icons.count { |icon| icon.name == 'port' }
          end
          if revenue.positive?
            bonus[:revenue] = revenue
            bonus[:description] = 'Port'
          end

          bonus
        end

        def gkb_bonus(route)
          bonus = { revenue: 0 }

          return bonus if !route.abilities || route.abilities.empty?
          raise GameError, "Only one ability supported: #{route.abilities}" if route.abilities.size > 1

          ability = abilities(route.train.owner, route.abilities.first, time: 'route')
          raise GameError, "Cannot find ability #{route.abilities.first}" unless ability

          bonuses = route.stops.count { |s| ability.hexes.include?(s.hex.name) }
          if bonuses.positive?
            amount = case ability.count
                     when 3
                       50
                     when 2
                       30
                     else
                       20
                     end
            bonus[:revenue] = amount * bonuses
            bonus[:description] = 'GKB'
            bonus[:description] += "x#{bonuses}" if bonuses > 1
          end

          bonus
        end

        def close_cleanup(company)
          cleanup_gkb(company) if company.sym == 'GKB'
          cleanup_sb(company) if company.sym == 'SB'
        end

        def cleanup_gkb(company)
          @log << "Removes icons for #{company.name}"
          remove_icons(GKB_HEXES, %w[GKB])
        end

        def cleanup_sb(company)
          @log << "Removes icons and token for #{company.name}"
          remove_icons(%w[A6 C2 D5 F19 F23 G26], %w[port sb_token])
          steam = sveabolaget&.id
          @hexes.select { |hex| hex.assigned?(sveabolaget.id) }.each { |h| h.remove_assignment!(steam) } if steam
        end

        def remove_icons(to_be_cleaned, icon_names)
          @hexes.each { |hex| remove_icon(hex, icon_names) if to_be_cleaned.include?(hex.name) }
        end

        def remove_icon(hex, icon_names)
          icon_names.each do |name|
            icons = hex.tile.icons
            icons.reject! { |i| name == i.name }
            hex.tile.icons = icons
          end
        end

        def friendly_city?(route, stop)
          corp = route.train.owner
          tokened_hex_by(stop.hex, corp)
        end

        def tokened_hex_by(hex, corporation)
          hex.tile.cities.any? { |c| c.tokened_by?(corporation) }
        end

        def owns_electric_train?(entity)
          entity.trains.any? { |t| t.name == 'E' }
        end
      end
    end
  end
end
