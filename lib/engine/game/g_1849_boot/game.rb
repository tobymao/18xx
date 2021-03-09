# frozen_string_literal: true

require_relative '../g_1849/game'
require_relative 'meta'

module Engine
  module Game
    module G1849Boot
      class Game < G1849::Game
        include_meta(G1849Boot::Meta)

        CURRENCY_FORMAT_STR = 'L.%d'

        BANK_CASH = 7760

        CERT_LIMIT = { 3 => 19, 4 => 14, 5 => 12, 6 => 10 }.freeze

        STARTING_CASH = { 3 => 500, 4 => 375, 5 => 300, 6 => 250 }.freeze

        MUST_SELL_IN_BLOCKS = true

        TILES = {
          '3' => 4,
          '4' => 4,
          '7' => 4,
          '8' => 10,
          '9' => 6,
          '58' => 4,
          '73' => 4,
          '74' => 3,
          '77' => 4,
          '78' => 10,
          '79' => 7,
          '644' => 2,
          '645' => 2,
          '657' => 2,
          '658' => 2,
          '659' => 2,
          '679' => 2,
          '23' => 3,
          '24' => 3,
          '25' => 2,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '624' => 1,
          '650' => 1,
          '660' => 1,
          '661' => 1,
          '662' => 1,
          '663' => 1,
          '664' => 1,
          '665' => 1,
          '666' => 1,
          '667' => 1,
          '668' => 1,
          '669' => 1,
          '670' => 1,
          '671' => 1,
          '677' => 3,
          '678' => 3,
          '680' => 1,
          '681' => 1,
          '682' => 1,
          '683' => 1,
          '684' => 1,
          '685' => 1,
          '686' => 1,
          '687' => 1,
          '688' => 1,
          '689' => 1,
          '690' => 1,
          '691' => 1,
          '692' => 1,
          '693' => 1,
          '694' => 1,
          '695' => 1,
          '699' => 2,
          '700' => 1,
          '701' => 1,
          '702' => 1,
          '703' => 1,
          '704' => 1,
          '705' => 1,
          '706' => 1,
          '707' => 1,
          '708' => 1,
          '709' => 1,
          '710' => 1,
          '711' => 1,
          '712' => 1,
          '713' => 1,
          '714' => 1,
          '715' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '646' => 1,
          '647' => 1,
          '648' => 1,
          '649' => 1,
          '672' => 1,
          '673' => 2,
          '674' => 2,
          '696' => 3,
          '697' => 2,
          '698' => 2,
          'X1' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'label=A;city=revenue:60,slots:2;path=a:1,b:_0,track:dual;path=a:4,b:_0;'\
                      'path=a:0,b:_0,track:narrow;path=a:5,b:_0,track:narrow',
          },
          'X2' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'label=N;city=revenue:50,slots:1;path=a:4,b:_0,track:narrow;'\
                      'path=a:5,b:_0;path=a:1,b:_0,track:dual',
          },
          'X3' => {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'label=R;city=revenue:30,slots:2;path=a:3,b:_0,track:dual;path=a:4,b:_0;path=a:2,b:_0,track:dual',
          },
          'X4' => {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'label=T;city=revenue:30,slots:2;path=a:2,b:_0,track:dual;path=a:1,b:_0,track:dual;path=a:5,b:_0',
          },
          'X5' => {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'label=A;city=revenue:90,slots:2;path=a:1,b:_0,track:dual;path=a:4,b:_0;'\
            'path=a:0,b:_0,track:dual;path=a:5,b:_0,track:dual',
          },
          'X6' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'label=N;city=revenue:90,slots:3;path=a:4,b:_0,track:dual;path=a:5,b:_0;'\
                      'path=a:1,b:_0,track:dual;path=a:3,b:_0',
          },
          'X7' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'label=R;city=revenue:90,slots:2;path=a:3,b:_0,track:dual;'\
                      'path=a:4,b:_0;path=a:2,b:_0,track:dual',
          },
          'X8' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'label=T;city=revenue:60,slots:2;path=a:2,b:_0,track:dual;'\
                      'path=a:1,b:_0,track:dual;path=a:5,b:_0;path=a:4,b:_0',
          },
        }.freeze

        LOCATION_NAMES = {
          'A7' => 'Terni',
          'A9' => "L'Aquila",
          'B14' => 'Pescara',
          'C5' => 'Roma',
          'C7' => 'Avezzano',
          'D10' => 'Isernia',
          'D14' => 'Vasto',
          'E11' => 'Campobasso',
          'F10' => 'Benevento',
          'F14' => 'Lucera',
          'F8' => 'Caserta',
          'G15' => 'Foggia',
          'G17' => 'Vieste',
          'G7' => 'Napoli',
          'G9' => 'Avellino',
          'H8' => 'Salerno',
          'I13' => 'Potenza',
          'J10' => 'Rofrano',
          'J16' => 'Matera',
          'J18' => 'Bari',
          'K9' => 'Scalea',
          'K13' => 'Metaponto',
          'L12' => 'Sibari',
          'L18' => 'Taranto',
          'L20' => 'Brindisi',
          'M9' => 'Cosenza',
          'N20' => 'Lecce',
          'N2' => 'Messina',
          'O11' => 'Crotone',
          'O19' => 'Ugento',
          'O5' => 'Vibo Valentia',
          'O9' => 'Catanzaro',
          'P2' => 'Reggio Calabria',
          'P6' => 'Siderno',
        }.freeze

        MARKET = [
          %w[72 83 95 107 120 133 147 164 182 202 224 248 276 306u 340u 377e],
          %w[63 72 82 93 104 116 128 142 158 175 195 216z 240 266u 295u 328u],
          %w[57 66 75 84 95 105 117 129 144x 159 177 196 218 242u 269u 298u],
          %w[54 62 71 80 90 100p 111 123 137 152 169 187 208 230],
          %w[52 59 68p 77 86 95 106 117 130 145 160 178 198],
          %w[47 54 62 70 78 87 96 107 118 131 146 162],
          %w[41 47 54 61 68 75 84 93 103 114 127],
          %w[34 39 45 50 57 63 70 77 86 95],
          %w[27 31 36 40 45 50 56],
          %w[0c 24 27 31],
        ].freeze

        PHASES = [
          {
            name: '4H',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
            status: ['gray_uses_white'],
          },
          {
            name: '6H',
            on: '6H',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[gray_uses_white can_buy_companies],
          },
          {
            name: '8H',
            on: '8H',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[gray_uses_gray can_buy_companies],
          },
          {
            name: '10H',
            on: '10H',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[gray_uses_gray can_buy_companies],
          },
          {
            name: '12H',
            on: '12H',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: ['gray_uses_black'],
          },
          {
            name: '16H',
            on: '16H',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[gray_uses_black blue_zone],
          },
        ].freeze

        TRAINS = [{ name: '4H', num: 5, distance: 4, price: 100, rusts_on: '8H' },
                  {
                    name: '6H',
                    num: 4,
                    distance: 6,
                    price: 200,
                    rusts_on: '10H',
                    events: [{ 'type' => 'green_par' }],
                  },
                  { name: '8H', num: 4, distance: 8, price: 350, rusts_on: '16H' },
                  {
                    name: '10H',
                    num: 3,
                    distance: 10,
                    price: 550,
                    events: [{ 'type' => 'brown_par' }],
                  },
                  {
                    name: '12H',
                    num: 1,
                    distance: 12,
                    price: 800,
                    events: [{ 'type' => 'close_companies' }, { 'type' => 'earthquake' }],
                  },
                  { name: '16H', num: 6, distance: 16, price: 1100 },
                  { name: 'R6H', num: 2, available_on: '16H', distance: 6, price: 600 }].freeze

        COMPANIES = [
          {
            name: 'Società Corriere',
            value: 20,
            revenue: 5,
            desc: 'Blocks Caserta (F8) while owned by a player.',
            sym: 'SCE',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['F8'] }],
            color: nil,
          },
          {
            name: 'Studio di Ingegneria Giuseppe Incorpora',
            value: 45,
            revenue: 10,
            desc: 'During its operating turn, the owning corporation can lay '\
                  'or upgrade standard gauge track on mountain, hill or rough '\
                  'hexes at half cost. Narrow gauge track is still at normal cost.',
            sym: 'SIGI',
            abilities: [
              {
                type: 'tile_discount',
                discount: 'half',
                terrain: 'mountain',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Compagnia Navale Mediterranea',
            value: 75,
            revenue: 15,
            desc: 'During its operating turn, the owning corporation may close '\
                  'this company to place the +L. 20 token on any port. The '\
                  'corporation that placed the token adds L. 20 to the revenue '\
                  'of the port for the rest of the game.',
            sym: 'CNM',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: %w[B16 G5 J20 L16],
                count: 1,
                owner_type: 'corporation',
              },
              {
                type: 'assign_corporation',
                when: 'sold',
                count: 1,
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Società Marittima Siciliana',
            value: 110,
            revenue: 20,
            desc: 'During its operating turn, the owning corporation may close '\
                  'this private company in lieu of performing both its tile '\
                  'and token placement steps. Performing this action allows '\
                  'the corporation to select any coastal city hex (all cities '\
                  'except Foggia, Campobasso, and Potenza), optionally lay or '\
                  'upgrade a tile there, and optionally place a station token '\
                  'there. This power may be used even if the corporation is '\
                  'unable to trace a route to that city, but all other normal '\
                  'tile placement and station token placement rules apply.',
            sym: 'SMS',
            abilities: [
              {
                type: 'description',
                description: 'Lay/upgrade and/or teleport on any coastal city',
              },
            ],
            color: nil,
          },
          {
            name: "Reale Società d'Affari",
            value: 150,
            revenue: 25,
            desc: 'Cannot be bought by a corporation. This private closes when '\
                  'the associated corporation buys its first train. If the '\
                  'associated corporation closes before buying a train, this '\
                  'private remains open until all private companies are closed '\
                  'at the start of Phase 12.',
            sym: 'RSA',
            abilities: [{ type: 'shares', shares: 'first_president' },
                        { type: 'no_buy' }],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 20,
            sym: 'SFR',
            name: 'Società per le Strade Ferrate Romane',
            logo: '1849_boot/SFR',
            token_fee: 40,
            tokens: [0, 0, 0],
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            always_market_price: true,
            color: '#ff0000',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'SFCS',
            name: 'Società per le Strade Ferrate Calabro-Sicule',
            logo: '1849_boot/SFCS',
            token_fee: 30,
            tokens: [0, 0, 0],
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            coordinates: 'O9',
            always_market_price: true,
            color: :green,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'AL',
            name: 'Società Adami e Lemmi',
            logo: '1849_boot/AL',
            token_fee: 40,
            tokens: [0, 0, 0],
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            coordinates: 'N20',
            always_market_price: true,
            color: '#f9b231',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'SFM',
            name: 'Società Italiana per le Strade Ferrate Meridionali',
            logo: '1849_boot/SFM',
            token_fee: 90,
            tokens: [0, 0, 0],
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            coordinates: 'B14',
            always_market_price: true,
            color: '#0189d1',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'IFP',
            name: 'Impresa Ferroviaria di Pietrarsa',
            logo: '1849_boot/IFP',
            token_fee: 130,
            tokens: [0, 0, 0],
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            coordinates: 'G7',
            always_market_price: true,
            color: '#f48221',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'PL',
            name: 'Società Anonima Pia Latina',
            logo: '1849_boot/PL',
            token_fee: 40,
            tokens: [0, 0, 0],
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            coordinates: 'G15',
            always_market_price: true,
            color: :pink,
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'FCU',
            name: 'Ferrovia Centrale Umbra',
            logo: '1849_boot/FCU',
            token_fee: 40,
            tokens: [0, 0, 0],
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            coordinates: 'A9',
            always_market_price: true,
            color: '#7b352a',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'M&C',
            name: 'Società in Commandita E. Melisurgo & C.',
            logo: '1849_boot/MC',
            token_fee: 90,
            tokens: [0, 0, 0],
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            coordinates: 'L18',
            always_market_price: true,
            color: '#000',
            reservation_color: nil,
          },
        ].freeze

        HEXES = {
          white: {
            %w[A11 A13 B12 D6 D8 E7 E15 F16 H14 I17 J8 K19 K15 M19 M21 N18 L10 O7] => '',
            ['H16'] => 'border=edge:3,type:impassable',
            %w[E9 E13 G13 H10 I9 N8] => 'upgrade=cost:40,terrain:mountain',
            %w[C13 F12 G11 I15 J14 K17 M11 O3] => 'upgrade=cost:80,terrain:mountain',
            %w[B8 B10 C11 D12 J12 K11 N10 P4 H12 I11 C9] => 'upgrade=cost:160,terrain:mountain',
            %w[L20 O9 G15 L12] => 'city=revenue:0',
            %w[E11] => 'city=revenue:0;upgrade=cost:40,terrain:mountain',
            %w[F8 F10 O5 M9] => 'town=revenue:0',
            ['G17'] => 'town=revenue:0;border=edge:0,type:impassable',
            %w[D14 F14 J10 J16] => 'town=revenue:0;upgrade=cost:40,terrain:mountain',
            ['K13'] => 'town=revenue:0;upgrade=cost:80,terrain:mountain',
            %w[D10 G9] => 'town=revenue:0;upgrade=cost:160,terrain:mountain',
          },
          blue: {
            ['B16'] => 'offboard=revenue:30,route:optional;path=a:1,b:_0,track:dual',
            ['J20'] => 'offboard=revenue:40,route:optional;path=a:1,b:_0,track:dual',
            %w[L16 G5] => 'offboard=revenue:40,route:optional;path=a:4,b:_0,track:dual',
          },
          gray: {
            ['A7'] => 'offboard=revenue:white_10|gray_40|black_60;path=a:4,b:_0,track:dual',
            ['N2'] => 'offboard=revenue:white_30|gray_50|black_80;path=a:0,b:_0,track:dual',
            ['C5'] => 'offboard=revenue:white_60|gray_90|black_120;path=a:5,b:_0,track:dual;path=a:4,b:_0,track:dual',
            ['O1'] => 'path=a:3,b:5,track:dual',
            ['N12'] => 'path=a:0,b:2,track:dual',
            ['C7'] => 'town=revenue:30;path=a:1,b:_0,track:narrow;path=a:4,b:_0,track:narrow',
            ['O11'] => 'town=revenue:20;path=a:3,b:_0,track:dual;path=a:1,b:_0,track:dual',
            ['O19'] => 'town=revenue:20;path=a:3,b:_0,track:dual',
            ['P6'] => 'town=revenue:20;path=a:3,b:_0,track:dual;path=a:2,b:_0,track:dual;'\
                      'path=a:1,b:_0,track:dual',
            ['K9'] => 'town=revenue:20;path=a:3,b:_0,track:dual;path=a:2,b:_0,track:dual;'\
                      'path=a:4,b:_0,track:dual;path=a:5,b:_0,track:dual',
            ['J18'] => 'city=slots:2,revenue:white_20|gray_30|black_40;path=a:4,b:_0,track:dual;'\
                       'path=a:2,b:_0;path=a:1,b:_0,track:narrow;path=a:5,b:_0',
            ['B14'] => 'city=revenue:white_20|gray_30|black_40,slots:2;path=a:0,b:_0,track:dual;'\
                       'path=a:1,b:_0,track:dual;path=a:2,b:_0,track:dual;path=a:4,b:_0,track:dual',
            ['I13'] => 'city=slots:2,revenue:white_20|gray_30|black_40;path=a:4,b:_0,track:dual;'\
                       'path=a:2,b:_0,track:dual;path=a:3,b:_0,track:dual;path=a:1,b:_0,track:dual;'\
                       'path=a:5,b:_0,track:dual;path=a:0,b:_0,track:dual;path=a:5,b:_0,track:dual',
            ['N20'] => 'city=slots:1,revenue:white_20|gray_30|black_40;path=a:0,b:_0,track:dual;'\
                       'path=a:3,b:_0,track:dual;path=a:2,b:_0,track:dual',
          },
          yellow: {
            ['A9'] => 'label=A;city=revenue:30;upgrade=cost:80,terrain:mountain;'\
                     'path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;path=a:5,b:_0,track:narrow;'\
                     'path=a:4,b:_0',
            ['P2'] => 'label=R;city=revenue:10;path=a:3,b:_0,track:narrow;path=a:4,b:_0',
            ['L18'] => 'label=T;city=revenue:20;path=a:2,b:_0,track:dual',
            ['G7'] => 'label=N;city=revenue:20;path=a:4,b:_0,track:narrow;path=a:5,b:_0',
            ['H8'] => 'city=revenue:10;path=a:2,b:_0',
          },
        }.freeze

        LAYOUT = :pointy

        NEW_SFR_HEXES = %w[E11 H8 I13 I17 J18 K19 L12 L20 O9 P2].freeze
        NEW_PORT_HEXES = %w[B16 G5 J20 L16].freeze
        NEW_SMS_HEXES = %w[B14 G7 H8 J18 L12 L18 L20 N20 O9 P2].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'green_par': ['144 Par Available',
                        'Corporations may now par at 144 (in addition to 67 and 100)'],
          'brown_par': ['216 Par Available',
                        'Corporations may now par at 216 (in addition to 67, 100, and 144)'],
          'earthquake': ['Avezzano Earthquake',
                         'Avezzano (C7) loses connection to Rome, revenue reduced to 10.']
        ).freeze

        AVZ_CODE = 'town=revenue:10;path=a:4,b:_0,track:narrow'.freeze

        NEW_GRAY_REVENUE_CENTERS =
          {
            'A7':
              {
                '4H': 10,
                '6H': 10,
                '8H': 40,
                '10H': 40,
                '12H': 60,
                '16H': 60,
              },
            'N2':
             {
               '4H': 30,
               '6H': 30,
               '8H': 50,
               '10H': 50,
               '12H': 80,
               '16H': 80,
             },
            'C5':
             {
               '4H': 60,
               '6H': 60,
               '8H': 90,
               '10H': 90,
               '12H': 120,
               '16H': 120,
             },
            'J18':
             {
               '4H': 20,
               '6H': 20,
               '8H': 30,
               '10H': 30,
               '12H': 40,
               '16H': 40,
             },
            'B14':
             {
               '4H': 20,
               '6H': 20,
               '8H': 30,
               '10H': 30,
               '12H': 40,
               '16H': 40,
             },
            'I13':
             {
               '4H': 20,
               '6H': 20,
               '8H': 30,
               '10H': 30,
               '12H': 40,
               '16H': 40,
             },
            'N20':
             {
               '4H': 20,
               '6H': 20,
               '8H': 30,
               '10H': 30,
               '12H': 40,
               '16H': 40,
             },
          }.freeze

        def home_token_locations(corporation)
          raise NotImplementedError unless corporation.name == 'SFR'

          NEW_SFR_HEXES.map { |coord| hex_by_id(coord) }.select do |hex|
            hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
          end
        end

        def check_other(route)
          return if (route.stops.map(&:hex).map(&:id) & NEW_PORT_HEXES).empty?
          raise GameError, 'Route must include two non-port stops.' unless route.stops.size > 2
        end

        def sms_hexes
          NEW_SMS_HEXES
        end

        def num_trains(train)
          case train[:name]
          when '6H'
            4
          when '8H'
            4
          when '16H'
            6
          end
        end

        def stop_revenue(stop, phase, train)
          return gray_revenue(stop) if NEW_GRAY_REVENUE_CENTERS.keys.include?(stop.hex.id)

          stop.route_revenue(phase, train)
        end

        def gray_revenue(stop)
          NEW_GRAY_REVENUE_CENTERS[stop.hex.id][@phase.name]
        end

        def event_earthquake!
          @log << '-- Event: Avezzano Earthquake --'
          new_tile = Engine::Tile.from_code('C7', :gray, AVZ_CODE)
          new_tile.location_name = 'Avezzano'
          hex_by_id('C7').tile = new_tile
        end

        def remove_corp; end
      end
    end
  end
end
