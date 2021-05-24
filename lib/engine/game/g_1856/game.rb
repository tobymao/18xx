# frozen_string_literal: true

require_relative 'meta'
require_relative '../../loan'
require_relative 'corporation'
require_relative '../base'

module Engine
  module Game
    module G1856
      class Game < Game::Base
        include_meta(G1856::Meta)

        register_colors(black: '#37383a',
                        orange: '#f48221',
                        brightGreen: '#76a042',

                        bbgPink: '#ffd9eb',
                        caRed: '#f72d2d',
                        cprPink: '#c474bc',
                        cvPurple: '#2d0047',
                        cgrBlack: '#000',
                        lpsBlue: '#c3deeb',
                        gtGreen: '#78c292',
                        gwGray: '#6e6966',
                        tgbOrange: '#c94d00',
                        thbYellow: '#ebff45',
                        wgbBlue: '#494d99',
                        wrBrown: '#54230e',

                        red: '#d81e3e',
                        turquoise: '#00a993',
                        blue: '#0189d1',
                        brown: '#7b352a')

        CURRENCY_FORMAT_STR = '$%d'

        BANK_CASH = 12_000

        CERT_LIMIT = { 3 => 20, 4 => 16, 5 => 13, 6 => 11 }.freeze

        STARTING_CASH = { 3 => 500, 4 => 375, 5 => 300, 6 => 250 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 3,
          '4' => 3,
          '5' => 2,
          '6' => 2,
          '7' => 7,
          '8' => 13,
          '9' => 13,
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
          '57' => 4,
          '58' => 3,
          '59' => 2,
          '63' => 4,
          '64' => 1,
          '65' => 1,
          '66' => 1,
          '67' => 1,
          '68' => 1,
          '69' => 1,
          '70' => 1,
          '120' => 1,
          '121' => 2,
          '122' => 1,
          '123' => 1,
          '124' => 1,
          '125' =>
          {
            'count' => 4,
            'color' => 'brown',
            'code' =>
            'city=revenue:40,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=L',
          },
          '126' => 1,
          '127' => 1,
        }.freeze

        LOCATION_NAMES = {
          'A20' => 'Detroit - Windsor',
          'A14' => 'Port Huron',
          'B13' => 'Sarnia',
          'F9' => 'Goderich',
          'H5' => 'Lake Huron',
          'K2' => 'Georgian Bay',
          'O2' => 'Canadian West',
          'Q8' => 'Lower Canada',
          'P17' => 'Buffalo',
          'F15' => 'London',
          'M4' => 'Barrie',
          'N11' => 'Toronto',
          'I12' => 'Kitchener',
          'I14' => 'Drumbo',
          'L15' => 'Hamilton',
          'N17' => 'Welland',
          'H15' => 'Woodstock',
          'J13' => 'Galt',
          'B19' => 'Chatham',
          'L13' => 'Burlington',
          'P9' => 'Oshawa',
          'F17' => 'St. Thomas',
          'O18' => 'Fort Erie',
          'C14' => 'Maudaumin',
          'D17' => 'Glencoe',
          'J11' => 'Guelph',
          'J15' => 'Brantford',
          'K8' => 'Orangeville',
          'O16' => 'Niagara Falls',
        }.freeze

        MARKET = [
          %w[70
             75
             80
             90
             100p
             110
             125
             150
             175
             200
             225
             250
             275
             300
             325
             350
             375
             400
             425
             450],
          %w[65
             70
             75
             80
             90p
             100
             110
             125
             150
             175
             200
             225
             250
             275
             300
             325
             350
             375
             400
             425],
          %w[60
             65
             70
             75
             80p
             90
             100
             110
             125
             150
             175
             200
             225
             250
             275],
          %w[55
             60
             65
             70
             75p
             80
             90
             100
             110
             125
             150
             175
             200],
          %w[50y 55 60 65 70p 75 80 90 100 110 125],
          %w[45y 50y 55 60 65p 70 75 80 90],
          %w[40o 45y 50y 55 60 65 70],
          %w[35o 40o 45y 50y 55 60],
          %w[30o 35o 40o 45y 50y],
          %w[0c 30o 35o 40o 45y],
          %w[0c 0c 30o 35o 40o],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            status: %w[escrow facing_2],
            operating_rounds: 1,
          },
          {
            name: "2'",
            on: "2'",
            train_limit: 4,
            tiles: [:yellow],
            status: %w[escrow facing_3],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[escrow facing_3 can_buy_companies],
          },
          {
            name: "3'",
            on: "3'",
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[escrow facing_4 can_buy_companies],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[escrow facing_4 can_buy_companies],
          },
          {
            name: "4'",
            on: "4'",
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[incremental facing_5 can_buy_companies],
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            status: %w[incremental facing_5],
            operating_rounds: 3,
          },
          {
            name: "5'",
            on: "5'",
            train_limit: 2,
            tiles: %i[yellow green brown],
            status: %w[fullcap facing_6],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            status: %w[fullcap facing_6],
            operating_rounds: 3,
          },
          {
            name: 'D',
            on: 'D',
            train_limit: 2,
            tiles: %i[yellow green brown gray black],
            status: %w[fullcap facing_6],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [{ name: '2', distance: 2, price: 100, rusts_on: '4', num: 5 },
                  { name: "2'", distance: 2, price: 100, rusts_on: '4', num: 1 },
                  { name: '3', distance: 3, price: 225, rusts_on: '6', num: 4 },
                  { name: "3'", distance: 3, price: 225, rusts_on: '6', num: 1 },
                  { name: '4', distance: 4, price: 350, rusts_on: 'D', num: 3 },
                  {
                    name: "4'",
                    distance: 4,
                    price: 350,
                    rusts_on: 'D',
                    num: 1,
                    events: [{ 'type' => 'no_more_escrow_corps' }],
                  },
                  {
                    name: '5',
                    distance: 5,
                    price: 550,
                    num: 2,
                    events: [{ 'type' => 'close_companies' }],
                  },
                  {
                    name: "5'",
                    distance: 5,
                    price: 550,
                    num: 1,
                    events: [{ 'type' => 'no_more_incremental_corps' }],
                  },
                  {
                    name: '6',
                    distance: 6,
                    price: 700,
                    num: 2,
                    events: [{ 'type' => 'nationalization' }, { 'type' => 'remove_tokens' }],
                  },
                  {
                    name: 'D',
                    distance: 999,
                    price: 1100,
                    num: 22,
                    available_on: '6',
                    discount: { '4' => 350, "4'" => 350, '5' => 350, "5'" => 350, '6' => 350 },
                  }].freeze

        COMPANIES = [
          {
            name: 'Flos Tramway',
            sym: 'FT',
            value: 20,
            revenue: 5,
            desc: 'No special abilities.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['L3'] }],
            color: nil,
          },
          {
            name: 'Waterloo & Saugeen Railway Co.',
            sym: 'WSRC',
            value: 40,
            revenue: 10,
            desc: 'The public company that owns this private company may place a free station marker and '\
            'green #59 tile on the Kitchener hex (I12). This action closes the private company.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['I12'] },
                        {
                          type: 'teleport',
                          owner_type: 'corporation',
                          hexes: ['I12'],
                          tiles: ['59'],
                        }],
            color: nil,
          },
          {
            name: 'The Canada Company',
            sym: 'TCC',
            value: 50,
            revenue: 10,
            desc: "During its operating turn, the public company owning this private company may place a '\
            'track tile in the hex occupied by this private company (H11). This track lay is in addition to '\
            'the public company's normal track lay. This action does not close the private company.",
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['H11'] },
                        {
                          type: 'tile_lay',
                          owner_type: 'corporation',
                          free: true,
                          hexes: ['H11'],
                          tiles: %w[3 4 58],
                          when: 'track',
                          count: 1,
                        }],
            color: nil,
          },
          {
            name: 'Great Lakes Shipping Company',
            sym: 'GLSC',
            value: 70,
            revenue: 15,
            desc: 'At any time during its operating turn, the owning public company may place the port token in '\
            'any one city adjacent to Lake Erie, Lake Huron or Georgian Bay. '\
            'Placement of this token closes the Great Lakes Shipping Company.',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: %w[C14
                          D19
                          E18
                          F17
                          F9
                          H17
                          H7
                          H5
                          J17
                          J5
                          K2
                          M18
                          O18],
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
            name: 'Niagara Falls Suspension Bridge Company',
            sym: 'NFSBC',
            value: 100,
            revenue: 20,
            desc: 'The public company that owns this private company may add a $10 bonus when running '\
            'to Buffalo (P17/P19). Other public companies may purchase the right for $50.',
            color: nil,
          },
          {
            name: 'St. Clair Frontier Tunnel Company',
            sym: 'SCFTC',
            value: 100,
            revenue: 20,
            desc: 'The public company that owns this private company may add a $10 Port Huron bonus when running '\
            'to Sarnia (B13). Other public companies may purchase the right for $50.',
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'BBG',
            logo: '1856/BBG',
            simple_logo: '1856/BBG.alt',
            name: 'Buffalo, Brantford & Goderich Railway',
            tokens: [0, 40, 100],
            coordinates: 'J15',
            color: '#ffd9eb',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: 'CA',
            logo: '1856/CA',
            simple_logo: '1856/CA.alt',
            name: 'Canada Air Line Railway',
            tokens: [0, 40, 100],
            coordinates: 'D17',
            color: '#f72d2d',
            reservation_color: nil,
          },
          {
            sym: 'CPR',
            logo: '1856/CPR',
            simple_logo: '1856/CPR.alt',
            name: 'Canadian Pacific Railroad',
            tokens: [0, 40, 100, 100],
            coordinates: 'M4',
            color: '#c474bc',
            reservation_color: nil,
          },
          {
            sym: 'CV',
            logo: '1856/CV',
            simple_logo: '1856/CV.alt',
            name: 'Credit Valley Railway',
            tokens: [0, 40, 100],
            coordinates: 'N11',
            city: 0,
            color: '#2d0047',
            reservation_color: nil,
          },
          {
            sym: 'GT',
            logo: '1856/GT',
            simple_logo: '1856/GT.alt',
            name: 'Grand Trunk Railway',
            tokens: [0, 40, 100, 100],
            coordinates: 'P9',
            color: '#78c292',
            reservation_color: nil,
          },
          {
            sym: 'GW',
            logo: '1856/GW',
            simple_logo: '1856/GW.alt',
            name: 'Great Western Railway',
            tokens: [0, 40, 100, 100],
            coordinates: 'F15',
            color: '#6e6966',
            reservation_color: nil,
          },
          {
            sym: 'LPS',
            logo: '1856/LPS',
            simple_logo: '1856/LPS.alt',
            name: 'London & Port Sarnia Railway',
            tokens: [0, 40],
            coordinates: 'C14',
            color: '#c3deeb',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: 'TGB',
            logo: '1856/TGB',
            simple_logo: '1856/TGB.alt',
            name: 'Toronto, Grey & Bruce Railway',
            tokens: [0, 40],
            coordinates: 'K8',
            color: '#c94d00',
            reservation_color: nil,
          },
          {
            sym: 'THB',
            logo: '1856/THB',
            simple_logo: '1856/THB.alt',
            name: 'Toronto, Hamilton and Buffalo Railway',
            tokens: [0, 40],
            coordinates: 'L15',
            color: '#ebff45',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: 'WR',
            logo: '1856/WR',
            simple_logo: '1856/WR.alt',
            name: 'Welland Railway',
            tokens: [0, 40, 100],
            coordinates: 'O16',
            color: '#54230e',
            reservation_color: nil,
          },
          {
            sym: 'WGB',
            logo: '1856/WGB',
            simple_logo: '1856/WGB.alt',
            name: 'Wellington, Grey & Bruce Railway',
            tokens: [0, 40],
            coordinates: 'J11',
            color: '#494d99',
            reservation_color: nil,
          },
          {
            sym: 'CGR',
            logo: '1856/CGR',
            simple_logo: '1856/CGR.alt',
            name: 'Canadian Government Railway',
            tokens: [],
            color: '#000',
            abilities: [
              {
                type: 'train_buy',
                description: 'Inter train buy/sell at face value',
                face_value: true,
              },
              {
                type: 'train_limit',
                increase: 99,
                description: '3 train limit',
              },
              {
                type: 'borrow_train',
                train_types: %w[8 D],
                description: 'May borrow a train when trainless*',
              },
            ],
            reservation_color: nil,
          },
        ].freeze

        HEXES = {
          red: {
            ['A20'] =>
                     'offboard=revenue:yellow_30|brown_50|black_60;path=a:4,b:_0;path=a:5,b:_0',
            ['A14'] => 'border=edge:4',
            ['B13'] =>
                   'offboard=revenue:yellow_30|brown_50;path=a:0,b:_0;path=a:5,b:_0;border=edge:1',
            ['H5'] =>
                   'offboard=revenue:yellow_30|brown_50|black_40;path=a:0,b:_0;path=a:5,b:_0;'\
                   'icon=image:port,sticky:1',
            ['K2'] =>
                   'offboard=revenue:yellow_20|brown_30;path=a:0,b:_0;path=a:5,b:_0;'\
                   'icon=image:port,sticky:1',
            ['N1'] =>
                   'offboard=revenue:yellow_20|brown_30|black_50,hide:1,groups:Canadian West;'\
                   'path=a:0,b:_0;path=a:1,b:_0;border=edge:5',
            ['O2'] =>
                   'offboard=revenue:yellow_20|brown_30|black_50,groups:Canadian West;'\
                   'path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;border=edge:2',
            ['Q8'] =>
                   'offboard=revenue:yellow_20|brown_30|black_50,groups:Lower Canada;'\
                   'path=a:1,b:_0;path=a:2,b:_0;border=edge:0',
            ['Q10'] =>
                   'offboard=revenue:yellow_20|brown_30|black_50,hide:1,groups:Lower Canada;'\
                   'path=a:2,b:_0;border=edge:3',
            ['P19'] =>
                   'offboard=revenue:yellow_30|brown_40,hide:1,groups:Buffalo;path=a:2,b:_0;border=edge:3',
            ['P17'] =>
                   'offboard=revenue:yellow_30|brown_40,groups:Buffalo;path=a:1,b:_0;path=a:2,b:_0;border=edge:0',
          },
          yellow: {
            %w[F15 M4] => 'city=revenue:30;path=a:0,b:_0;path=a:4,b:_0',
            ['N11'] =>
            'city=revenue:30;city=revenue:30;label=T;path=a:1,b:_0;path=a:4,b:_1',
            %w[I12 N17] => 'city=revenue:0;city=revenue:0;label=OO',
            ['L15'] =>
            'city=revenue:0;city=revenue:0;label=OO;upgrade=cost:40,terrain:mountain',
          },
          blue: { ['N5'] => '' },
          gray: {
            ['F9'] =>
                        'town=revenue:yellow_30|brown_50|black_40;'\
                        'path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;icon=image:port,sticky:1',
          },
          white: {
            %w[H15 G12 I8 J13 D17 J11 J15 K8 O16] =>
                     'city=revenue:0',
            %w[B19 L13 P9] => 'city=revenue:0;label=L',
            %w[C14 F17 O18] => 'city=revenue:0;label=L;icon=image:port,sticky:1',
            ['N3'] => 'city=revenue:0;label=L;upgrade=cost:40,terrain:water',
            %w[J9 K16 L9 M6 N9 H11] => 'town=revenue:0',
            %w[D19 H17 J5 M18] => 'town=revenue:0;icon=image:port,sticky:1',
            %w[I14 F13 M10] => 'town=revenue:0;town=revenue:0',
            %w[E18 H7 J17] =>
            'town=revenue:0;town=revenue:0;icon=image:port,sticky:1',
            %w[K10 K12 K14 M16 N15] => 'upgrade=cost:40,terrain:mountain',
            %w[N19 P7] => 'upgrade=cost:40,terrain:water',
            %w[L3
               B15
               B17
               B21
               C16
               C18
               C20
               D13
               D15
               E12
               E14
               E16
               F11
               G8
               G10
               G14
               G16
               G18
               H9
               H13
               I6
               I10
               I16
               I18
               J7
               K4
               K6
               K18
               L5
               L7
               L11
               L17
               M2
               M8
               M12
               N7
               O4
               O6
               O8
               O10
               P3
               P5] => 'blank',
          },
        }.freeze

        LAYOUT = :flat

        attr_reader :post_nationalization, :bankrupted
        attr_accessor :borrowed_trains, :national_ever_owned_permanent, :false_national_president,
                      :nationalization_train_discard_trigger

        # These plain city hexes upgrade to L tiles in brown
        LAKE_HEXES = %w[B19 C14 F17 O18 P9 N3 L13].freeze
        BROWN_OO_TILES = %w[64 65 66 67 68].freeze
        PORT_HEXES = %w[C14 D19 E18 F17 F9 H17 H7 H5 J17 J5 K2 M18 O18].freeze

        # These cities upgrade to the common BarrieLondon green tile,
        #  but upgrade to specialized brown tiles
        BARRIE_HEX = 'M4'
        LONDON_HEX = 'F15'
        HAMILTON_HEX = 'L15'

        # This is unlimited in 1891
        # They're also 5% shares if there are more than 20 shares. It's weird.
        NATIONAL_MAX_SHARE_PERCENT_AWARDED = 200

        SELL_MOVEMENT = :down_per_10

        HOME_TOKEN_TIMING = :operating_round

        RIGHT_COST = 50

        PRE_NATIONALIZATION_CERT_LIMIT = { 3 => 20, 4 => 16, 5 => 13, 6 => 11 }.freeze
        POST_NATIONALIZATION_CERT_LIMIT = {
          11 => { 3 => 28, 4 => 22, 5 => 18, 6 => 15 },
          10 => { 3 => 25, 4 => 20, 5 => 16, 6 => 14 },
          9 => { 3 => 22, 4 => 18, 5 => 15, 6 => 12 },
          8 => { 3 => 20, 4 => 16, 5 => 13, 6 => 11 },
          7 => { 3 => 18, 4 => 14, 5 => 11, 6 => 10 },
          6 => { 3 => 15, 4 => 12, 5 => 10, 6 => 8 },
          5 => { 3 => 13, 4 => 10, 5 => 8, 6 => 7 },
          4 => { 3 => 10, 4 => 8, 5 => 7, 6 => 6 },
          3 => { 3 => 10, 4 => 8, 5 => 7, 6 => 6 },
          2 => { 3 => 10, 4 => 8, 5 => 7, 6 => 6 },
          1 => { 3 => 10, 4 => 8, 5 => 7, 6 => 6 },
        }.freeze

        DESTINATIONS = {
          'BBG' => 'N17',
          'CA' => 'H15',
          'CPR' => 'N11',
          'CV' => 'I14',
          'GT' => 'K8',
          'GW' => 'A20',
          'LPS' => 'F17',
          'TGB' => 'H5',
          'THB' => 'J11',
          'WGB' => 'F9',
          'WR' => 'L15',
        }.freeze

        ALTERNATE_DESTINATIONS = {
          'BBG' => 'N11',
          'CA' => %w[A20 F15], # Connect London to Detroit
          'CPR' => 'P9',
          'CV' => 'M4',
          'GT' => 'L13',
          'GW' => 'J15',
          'LPS' => 'F15',
          'TGB' => [%w[O2 N1]], # Canadian West, but it's a 2 hex offboard
          'THB' => 'H15',
          'WGB' => 'H5',
          'WR' => 'L15',
        }.freeze

        # TODO: Get a proper token
        ASSIGNMENT_TOKENS = {
          'GLSC' => '/icons/1846/sc_token.svg',
        }.freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          {
            'nationalization' => ['CGR Formation',
                                  'Corporations must pay back loans or forcefully be merged into the CGR.' \
                                  ' Presidents may contribute personal cash but may not sell shares.' \
                                  ' CGR does not form if all corporations pay back their loans'],
            'remove_tokens' => ['Remove Port Token'],
            'no_more_escrow_corps' => ['New Corporations are Incremental Cap',
                                       'Does not affect corporations which have already been parred'],
            'no_more_incremental_corps' => ['New Corporations are Full Cap',
                                            'Does not affect corporations which have already been parred'],
          }
        ).freeze
        FALSE_PRESIDENCY_ABILITY = Ability::Description.new(
          type: 'description',
          description: '(Temporary) 1-Share presidency'
        )
        POST_NATIONALIZATION_TRAIN_ABILITY = Ability::TrainLimit.new(
          type: 'train_limit',
          description: 'Train Limit of 3',
          increase: 1
        )
        TWENTY_SHARE_NATIONAL_ABILITY = Ability::Description.new(
          type: 'description',
          description: '20 Share Corporation'
        )
        NATIONAL_IMMOBILE_SHARE_PRICE_ABILITY = Ability::Description.new(
          type: 'description',
          description: 'Share price may not change',
          desc_detail: 'Share price may not change until this corporation has owned a permanent train'
        )
        NATIONAL_FORCED_WITHHOLD_ABILITY = Ability::Description.new(
          type: 'description',
          description: 'May not pay dividends',
          desc_detail: 'Must withhold earnings until this corporation has owned a permanent train'
        )
        def national
          @national ||= corporation_by_id('CGR')
        end

        def gray_phase?
          @phase.tiles.include?(:gray)
        end

        def revenue_for(route, stops)
          revenue = super

          revenue += 20 if route.corporation.assigned?(port.id) && stops.any? { |stop| stop.hex.assigned?(port.id) }

          route.corporation.all_abilities.select { |a| a.type == :hex_bonus }.each do |ability|
            revenue += stops.map { |s| s.hex.id }.uniq.sum { |id| ability.hexes.include?(id) ? ability.amount : 0 }
          end
          revenue
        end

        def port
          @port ||= company_by_id('GLSC')
        end

        def tunnel
          @tunnel ||= company_by_id('SCFTC')
        end

        def bridge
          @bridge ||= company_by_id('NFSBC')
        end

        def maximum_loans(entity)
          entity.num_player_shares
        end

        def loan_value
          100
        end

        def interest_rate
          10
        end

        def national_token_price
          100
        end

        # There are 11 corporations in the game and keeping corporation homes is mandatory; so this can
        # (rarely) be broken
        def national_token_limit
          10
        end

        def ultimate_train_price
          1100
        end

        def ultimate_train_trade_in
          750
        end

        def interest_owed_for_loans(loans)
          interest_rate * loans
        end

        def interest_owed(entity)
          interest_owed_for_loans(entity.loans.size)
        end

        def take_loan(entity, loan)
          raise GameError, 'Cannot take loan' unless can_take_loan?(entity)

          name = entity.name
          loan_amount = @round.paid_interest[entity] ? loan_value - interest_rate : loan_value
          @log << "#{name} takes a loan and receives #{format_currency(loan_amount)}"
          @bank.spend(loan_amount, entity)
          entity.loans << loan
          @loans.delete(loan)
        end

        def can_take_loan?(entity)
          entity.corporation? &&
            entity.loans.size < maximum_loans(entity) &&
            !@round.took_loan[entity] &&
            !@round.redeemed_loan[entity] &&
            @loans.any? &&
            !@post_nationalization
        end

        def num_loans
          # @corporations is not available at the time of init_loans
          110
        end

        def init_loans
          Array.new(num_loans) { |id| Loan.new(id, loan_value) }
        end

        def can_pay_interest?(_entity, _extra_cash = 0)
          # TODO: A future PR may figure out how to implement buying_power
          #  that accounts for a corporations revenue.
          true
        end

        def init_stock_market
          stock_market = G1856::StockMarket.new(game_market, self.class::CERT_LIMIT_TYPES,
                                                multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
          stock_market.game = self
          stock_market
        end

        def init_corporations(stock_market)
          min_price = stock_market.par_prices.map(&:price).min

          self.class::CORPORATIONS.map do |corporation|
            G1856::Corporation.new(
              self,
              min_price: min_price,
              capitalization: nil,
              **corporation.merge(corporation_opts),
            )
          end
        end

        def setup
          @straight_city ||= @tiles.find { |t| t.name == '57' }
          @sharp_city ||= @tiles.find { |t| t.name == '5' }
          @gentle_city ||= @tiles.find { |t| t.name == '6' }

          @straight_track ||= @tiles.find { |t| t.name == '9' }
          @sharp_track ||= @tiles.find { |t| t.name == '7' }
          @gentle_track ||= @tiles.find { |t| t.name == '8' }

          @x_city ||= @tiles.find { |t| t.name == '14' }
          @k_city ||= @tiles.find { |t| t.name == '15' }

          @brown_london ||= @tiles.find { |t| t.name == '126' }
          @brown_barrie ||= @tiles.find { |t| t.name == '127' }

          @gray_hamilton ||= @tiles.find { |t| t.name == '123' }

          @post_nationalization = false
          @nationalization_train_discard_trigger = false
          @national_formed = false

          @pre_national_percent_by_player = {}
          @pre_national_market_percent = 0

          @pre_national_market_prices = {}
          @nationalized_corps = []

          @bankrupted = false

          # Is the president of the national a "false" president?
          # A false president gets the presidency with only one share; in this case the president gets
          # the full president's certificate but is obligated to buy up to the full presidency in the
          # following SR unless a different player becomes rightfully president during share exchange
          # It is impossible for someone who didn't become president in
          # exchange (1 share tops) to steal the presidency in the SR because
          # they'd have to buy 2 shares in one action which is a no-no
          # nil: Presidency not awarded yet at all
          # not-nl: 1-share false presidency has been awarded to the player (value of var)
          @false_national_president = nil

          # CGR flags
          @national_ever_owned_permanent = false

          # 1 of each right is reserved w/ the private when it gets bought in. This leaves 2 extra to sell.
          available_tokens = @optional_rules&.include?(:unlimited_bonus_tokens) ? 99 : 2
          @available_bridge_tokens = available_tokens
          @available_tunnel_tokens = available_tokens

          # Corp -> Borrowed Train
          @borrowed_trains = {}
          create_destinations(
            @optional_rules&.include?(:alternate_destinations) ? ALTERNATE_DESTINATIONS : DESTINATIONS
          )
          national.add_ability(self.class::NATIONAL_IMMOBILE_SHARE_PRICE_ABILITY)
          national.add_ability(self.class::NATIONAL_FORCED_WITHHOLD_ABILITY)
        end

        def create_destinations(destinations)
          @destinations = {}
          destinations.each do |corp, dest|
            dest_arr = Array(dest)
            d_goals = Array(dest_arr.first)
            d_start = dest_arr.size > 1 ? dest_arr.last : corporation_by_id(corp).coordinates
            ability = Ability::Base.new(
                type: 'destination',
                description: "Connect #{hex_by_id(d_start).tile.location_name} to"\
                  " #{hex_by_id(d_goals.first).tile.location_name}"
              )
            corporation_by_id(corp).add_ability(ability)
            dest_arr.each do |d|
              # Array(d).first allows us to treat 'E5' or %[O2 N3] identically
              hex_by_id(Array(d).first).original_tile.icons << Part::Icon.new("../logos/1856/#{corp}")
            end
            @destinations[corp] = [d_start, d_goals].freeze
          end
        end

        def num_corporations
          # Before nationalization, the national is in @corporations but doesn't count
          # After nationalization, if the national is in corporations it does count
          @post_nationalization ? @corporations.size : @corporations.size - 1
        end

        def cert_limit
          return PRE_NATIONALIZATION_CERT_LIMIT[@players.size] unless @post_nationalization

          POST_NATIONALIZATION_CERT_LIMIT[num_corporations][@players.size]
        end

        def destination_connected?(corp)
          corp.capitalization == :escrow && hexes_connected?(*@destinations[corp.id])
        end

        def hexes_connected?(start_hex_id, goal_hex_ids)
          tokens = hex_by_id(start_hex_id).tile.cities.map { |city| [city, true] }.to_h

          tokens.keys.each do |node|
            visited = tokens.reject { |token, _| token == node }

            node.walk(visited: visited, corporation: nil) do |path, _|
              return true if goal_hex_ids.include?(path.hex.id)
            end
          end

          false
        end

        def destinated!(corp)
          @log << "-- #{corp.name} has destinated --"
          remove_dest_icons(corp)
          release_escrow!(corp)
        end

        def remove_dest_icons(corp)
          return unless @destinations[corp.id]

          @destinations[corp.id].each do |dest|
            Array(dest).each { |id| hex_by_id(id).tile.icons.reject! { |i| i.name == corp.id } }
          end
        end

        #
        # Get the currently possible upgrades for a tile
        # from: Tile - Tile to upgrade from
        # to: Tile - Tile to upgrade to
        # special - ???
        def upgrades_to?(from, to, _special = false, selected_company: nil)
          return false if from.name == '470'
          # double dits upgrade to Green cities in gray
          return gray_phase? if to.name == '14' && %w[55 1].include?(from.name)
          return gray_phase? if to.name == '15' && %w[56 2].include?(from.name)

          # yellow dits upgrade to yellow cities in gray
          return gray_phase? if to.name == '5' && from.name == '3'
          return gray_phase? if to.name == '57' && from.name == '4'
          return gray_phase? if to.name == '6' && from.name == '58'

          # yellow dits upgrade to plain track in gray
          return gray_phase? if to.name == '7' && from.name == '3'
          return gray_phase? if to.name == '9' && from.name == '4'
          return gray_phase? if to.name == '8' && from.name == '58'

          # Certain green cities upgrade to other labels
          return to.name == '127' if from.color == :green && from.hex.name == BARRIE_HEX
          return to.name == '126' if from.color == :green && from.hex.name == LONDON_HEX
          # You may lay the brown 5-spoke L if and only if it is laid on a L hex -
          # NOT EVEN IF YOU GREEN A DOUBLE DIT ON A LAKE EDTGE
          return to.name == '125' if from.color == :green && LAKE_HEXES.include?(from.hex.name)
          # The L hexes on the map start as plain yellow cities
          return %w[5 6 57].include?(to.name) if LAKE_HEXES.include?(from.hex.name) && from.color == :white
          # B,L to B-L
          return to.name == '121' if from.color == :yellow && [BARRIE_HEX, LONDON_HEX].include?(from.hex.name)
          # Hamilton OO upgrade is yet another case of ignoring labels in upgrades
          return to.name == '123' if from.color == :brown && from.hex.name == HAMILTON_HEX

          super
        end

        def can_par?(corporation, parrer)
          return false if @false_national_president && parrer == @false_national_president

          corporation == national ? national.ipoed : super
        end

        #
        # Get all possible upgrades for a tile
        # tile: The tile to be upgraded
        # tile_manifest: true/false Is this being called from the tile manifest screen
        #
        def all_potential_upgrades(tile, tile_manifest: false, selected_company: nil)
          upgrades = super
          return upgrades unless tile_manifest

          # In phase 6+ single dits may be turned into plain yellow track or yellow cities
          if gray_phase?
            upgrades |= [@straight_city, @straight_track] if tile.name == '4'
            upgrades |= [@gentle_city, @gentle_track] if tile.name == '58'
            upgrades |= [@sharp_city, @sharp_track] if tile.name == '3'
            # furthermore, double dits may be upgraded to green cities, if track can be preserved
            upgrades |= [@x_city] if tile.name == '55'
            upgrades |= [@x_city] if tile.name == '1'
            upgrades |= [@k_city] if tile.name == '56'
            upgrades |= [@k_city] if tile.name == '2'
          end
          upgrades |= [@brown_london] if tile.name == '121'
          upgrades |= [@brown_barrie] if tile.name == '121'
          upgrades |= [@gray_hamilton] if BROWN_OO_TILES.include?(tile.name)
          upgrades
        end

        def can_go_bankrupt?(player, corporation)
          # Corporation is nil in the case of interest / loan bankruptcies
          return liquidity(player, emergency: true).negative? unless corporation

          super
        end

        def float_corporation(corporation)
          corporation.float!
          super
        end

        def operating_order
          @corporations.select { |c| c.floated? || c.floatable? }.sort
        end

        def release_escrow!(corporation)
          @log << "Releasing #{format_currency(corporation.escrow)} from escrow for #{corporation.name}"
          @bank.spend(corporation.escrow, corporation) if corporation.escrow.positive?
          corporation.escrow = nil
          corporation.capitalization = :incremental
        end

        def can_buy_tunnel_token?(entity)
          return false unless entity.corporation?
          return false if tunnel.owned_by_player?

          @available_tunnel_tokens.positive? && !tunnel?(entity) && buying_power(entity) >= RIGHT_COST
        end

        def can_buy_bridge_token?(entity)
          return false unless entity.corporation?
          return false if bridge.owned_by_player?

          @available_bridge_tokens.positive? && !bridge?(entity) && buying_power(entity) >= RIGHT_COST
        end

        def buy_tunnel_token(entity)
          seller = tunnel.closed? ? @bank : tunnel.owner
          seller_name = tunnel.closed? ? 'the bank' : tunnel.owner.name
          @log << "#{entity.name} buys a tunnel token from #{seller_name} for #{format_currency(RIGHT_COST)}"
          entity.spend(RIGHT_COST, seller)
          @available_tunnel_tokens -= 1
          grant_right(entity, :tunnel)
        end

        def buy_bridge_token(entity)
          seller = bridge.closed? ? @bank : bridge.owner
          seller_name = bridge.closed? ? 'the bank' : bridge.owner.name
          @log << "#{entity.name} buys a bridge token from #{seller_name} for #{format_currency(RIGHT_COST)}"
          entity.spend(RIGHT_COST, seller)
          @available_bridge_tokens -= 1
          grant_right(entity, :bridge)
        end

        def tunnel?(corporation)
          # abilities will return an array if many or an Ability if one. [*foo(bar)] gets around that
          corporation.all_abilities.any? { |ability| ability.type == :hex_bonus && ability.hexes.include?('B13') }
        end

        def bridge?(corporation)
          # abilities will return an array if many or an Ability if one. [*foo(bar)] gets around that
          corporation.all_abilities.any? { |ability| ability.type == :hex_bonus && ability.hexes.include?('P17') }
        end

        def grant_right(corporation, type)
          corporation.add_ability(Engine::Ability::HexBonus.new(
            type: :hex_bonus,
            description: "+10 bonus when running to #{type == :tunnel ? 'Sarnia' : 'Buffalo'}",
            hexes: type == :tunnel ? %w[B13] : %w[P17 P19],
            amount: 10,
            owner_type: :corporation
          ))
        end

        def event_no_more_escrow_corps!
          @log << 'New corporations will be started as incremental cap corporations'
          @corporations.reject(&:capitalization).each { |c| remove_dest_icons(c) }
        end

        def event_no_more_incremental_corps!
          @log << 'New corporations will be started as full cap corporations'
        end

        def event_close_companies!
          # The tokens reserved for the company's buyer are sent to the bank if closed before being bought in
          @available_bridge_tokens += 1 if bridge.owned_by_player?
          @available_tunnel_tokens += 1 if tunnel.owned_by_player?
          super
        end

        def company_bought(company, entity)
          grant_right(entity, :bridge) if company == bridge
          grant_right(entity, :tunnel) if company == tunnel
        end

        # Trying to do {static literal}.merge(super.static_literal) so that the capitalization shows up first.
        STATUS_TEXT = {
          'escrow' => [
            'Escrow Cap',
            'New corporations will be capitalized for the first 5 shares sold.'\
            ' The money for the last 5 shares is held in escrow until'\
            ' the corporation has destinated',
          ],
          'incremental' => [
            'Incremental Cap',
            'New corporations will be capitalized for all 10 shares as they are sold'\
            ' regardless of if a corporation has destinated',
          ],
          'fullcap' => [
            'Full Cap',
            'New corporations will be capitalized for 10 x par price when 60% of the IPO is sold',
          ],
          'facing_2' => [
            '20% to start',
            'An unstarted corporation needs 20% sold from the IPO to start for the first time',
          ],
          'facing_3' => [
            '30% to start',
            'An unstarted corporation needs 30% sold from the IPO to start for the first time',
          ],
          'facing_4' => [
            '40% to start',
            'An unstarted corporation needs 40% sold from the IPO to start for the first time',
          ],
          'facing_5' => [
            '50% to start',
            'An unstarted corporation needs 50% sold from the IPO to start for the first time',
          ],
          'facing_6' => [
            '60% to start',
            'An unstarted corporation needs 60% sold from the IPO to start for the first time',
          ],
        }.merge(Base::STATUS_TEXT)
        def operating_round(round_num)
          G1856::Round::Operating.new(self, [
            G1856::Step::Bankrupt,
            G1856::Step::CashCrisis,
            # No exchanges.
            G1856::Step::Assign,
            G1856::Step::Loan,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,

            # Nationalization!!
            G1856::Step::NationalizationPayoff,
            G1856::Step::RemoveTokens,
            G1856::Step::NationalizationDiscardTrains,
            G1856::Step::SpecialBuy,
            G1856::Step::Track,
            G1856::Step::Escrow,
            G1856::Step::Token,
            G1856::Step::BorrowTrain,
            Engine::Step::Route,
            # Interest - See Loan
            G1856::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1856::Step::BuyTrain,
            # Repay Loans - See Loan
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def stock_round
          G1856::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            G1856::Step::BuySellParShares,
          ])
        end

        def event_remove_tokens!
          removals = Hash.new { |h, k| h[k] = {} }

          @corporations.each do |corp|
            corp.assignments.dup.each do |company, _|
              removals[company][:corporation] = corp.name
              corp.remove_assignment!(company)
            end
          end

          @hexes.each do |hex|
            hex.assignments.dup.each do |company, _|
              removals[company][:hex] = hex.name
              hex.remove_assignment!(company)
            end
          end

          self.class::PORT_HEXES.each do |hex|
            hex_by_id(hex).tile.icons.reject! do |icon|
              %w[port].include?(icon.name)
            end
          end

          removals.each do |company, removal|
            hex = removal[:hex]
            corp = removal[:corporation]
            @log << "-- Event: #{corp}'s #{company_by_id(company).name} token removed from #{hex} --"
          end
        end

        # Nationalization Methods

        def event_nationalization!
          @nationalization_trigger ||= train_by_id('6-0').owner.owner
          @log << '-- Event: CGR merger --'
          corporations_repay_loans
          # Now that we have determined the triggerer for nationalization we can get them in order
          @nationalizables = nationalizable_corporations
          @log << "Merge candidates: #{present_nationalizables(nationalizables)}" if nationalizables.any?
          # starting with the player who bought the 6 train, go around the table repaying loans

          # player picks order of their companies.
          # set aside compnanies that do not repay succesfully

          # starting with the player who bought the 6 train, go around the table trading shares
          # trade all shares
        end

        def nationalizables
          @nationalizables ||= []
        end

        def max_national_shares
          20
        end

        def corporations_repay_loans
          @corporations.each do |corp|
            next unless corp.floated? && corp.loans.size.positive?

            loans_repaid = [corp.loans.size, (corp.cash / loan_value).to_i].min
            amount_repaid = loan_value * loans_repaid
            next unless amount_repaid.positive?

            corp.spend(amount_repaid, @bank)
            @loans << corp.loans.pop(loans_repaid)
            @log << "#{corp.name} repays #{format_currency(amount_repaid)} to redeem #{loans_repaid} loans"
          end
        end

        def national_bought_permanent
          return if @national_ever_owned_permanent

          @national_ever_owned_permanent = true
          national.remove_ability(self.class::NATIONAL_FORCED_WITHHOLD_ABILITY)
          national.remove_ability(self.class::NATIONAL_IMMOBILE_SHARE_PRICE_ABILITY)
          @log << "-- #{national.name} now owns a permanent train, may no longer borrow a train when trainless --"
          national.remove_ability(national.all_abilities.find { |a| a.type == :borrow_train })
        end

        def merge_major(major)
          @national_formed = true
          @log << "-- #{major.name} merges into #{national.name} --"
          # Trains are transferred
          major.trains.dup.each do |t|
            national_bought_permanent unless t.rusts_on
            buy_train(national, t, :free)
          end
          # Leftover cash is transferred
          major.spend(major.cash, national) if major.cash.positive?
          @loans << major.loans.pop(major.loans.size)
          # Tunnel / Bridge rights are transferred
          if tunnel?(major)
            if tunnel?(national)
              @log << "#{national.name} already has a tunnel token, the token is returned to the bank pool"
              @available_tunnel_tokens += 1
            else
              @log << "#{national.name} gets #{major.name}'s tunnel token"
              grant_right(national, :tunnel)
            end
          end
          if bridge?(major)
            if bridge?(national)
              @log << "#{national.name} already has a bridge token, the token is returned to the bank pool"
              @available_bridge_tokens += 1
            else
              @log << "#{national.name} gets #{major.name}'s bridge token"
              grant_right(national, :bridge)
            end
          end

          # Tokens:
          # Remove reservations

          hexes.each do |hex|
            hex.tile.cities.each do |city|
              if city.tokened_by?(major)
                city.tokens.map! { |token| token&.corporation == major ? nil : token }
                city.reservations.delete(major)
              end
            end
          end

          # Shares
          merge_major_shares(major)
          @pre_national_market_prices[major.name] = major.share_price.price
          @nationalized_corps << major
          # Corporation will close soon, but not now. See post_corp_nationalization
          nationalizables.delete(major)
          post_corp_nationalization
        end

        def merge_major_shares(major)
          major.player_share_holders.each do |player, num|
            @pre_national_percent_by_player[player] ||= 0
            @pre_national_percent_by_player[player] += num
          end
          @pre_national_market_percent += major.num_market_shares * 10
        end

        # Issue more shares
        # Must be called while shares are still all in the IPO.
        def national_issue_shares!
          return unless national.total_shares == 10

          @log << "#{national.name} issues 10 more shares and all shares are now 5% shares"
          national.shares_by_corporation[national].each_with_index do |share, index|
            # Presidents cert is a 10% 2-share 1-cert paper, everything else is a 5% 1-share 0.5-cert paper
            share.percent = index.zero? ? 10 : 5
            share.cert_size = index.zero? ? 1 : 0.5
          end

          num_shares = national.total_shares
          10.times do |i|
            new_share = Share.new(national, percent: 5, index: num_shares + i, cert_size: 0.5)
            @_shares[new_share.id] = new_share
            national.shares_by_corporation[national] << new_share
          end
          national.add_ability(self.class::TWENTY_SHARE_NATIONAL_ABILITY)
        end

        def calculate_national_price
          prices = @pre_national_market_prices.values
          # If more than two companies merging in drop the lowest share price
          prices.delete_at(prices.index(prices.min)) if prices.size > 2

          # Average the values of the companies and round *down* to the nearest $5 increment
          ave = (0.2 * prices.sum / prices.size).to_i * 5

          # The value is 100 at the bare minimum
          # Also the stock market increases as such:
          # 90 > 100 > 110 > 125 > 150
          market_price = if ave < 105
                           100
                         # The next share value is 110
                         elsif ave <= 115
                           110
                         # everything else is multiples of 25
                         else
                           delta = ave % 25
                           delta < 12.5 ? ave - delta : ave - delta + 25
                         end

          # The stock market token is placed on the top row
          @stock_market.market[0].find { |p| p.price == market_price }
        end

        def float_str(entity)
          return 'Floats in phase 6' if entity == national

          super
        end

        def float_national
          national.float!
          @stock_market.set_par(national, calculate_national_price)
          national.ipoed = true
        end

        # Handles the share exchange in nationalization
        # Returns the president Player
        def national_share_swap
          index_for_trigger = @players.index(@nationalization_trigger)
          # This is based off the code in 18MEX; 10 appears to be an arbitrarily large integer
          #  where the exact value doesn't really matter
          players_in_order = (0..@players.count - 1).to_a.sort_by { |i| i < index_for_trigger ? i + 10 : i }
          # Determine the president before exchanging shares for ease of distribution
          shares_left_to_distribute = max_national_shares
          president_shares = 0
          president = nil
          players_in_order.each do |i|
            player = @players[i]
            next unless @pre_national_percent_by_player[player]

            shares_awarded = [(@pre_national_percent_by_player[player] / 20).to_i, shares_left_to_distribute].min
            # Single shares that are discarded to the market
            @pre_national_market_percent += @pre_national_percent_by_player[player] % 20
            shares_left_to_distribute -= shares_awarded
            @log << "#{player.name} gets #{shares_awarded} shares of #{national.name}"

            next unless shares_awarded > president_shares

            @log << "#{player.name} becomes president of the #{national.name}"
            if shares_awarded == 1
              @log << "#{player.name} will need to buy the 2nd share of the #{national.name} "\
                "president's cert in the next SR unless a new president is found"
              @false_national_president = player
              national.add_ability(FALSE_PRESIDENCY_ABILITY)
            elsif @false_national_president
              @log << "Since #{president.name} is no longer president of the #{national.name} "\
                ' and is no longer obligated to buy a second share in the following SR'
              @false_national_president = nil
              national.remove_ability(FALSE_PRESIDENCY_ABILITY)
            end
            president_shares = shares_awarded
            president = player
          end
          # Determine how many market shares need to be issued; this may trigger a second issue of national shares
          national_market_share_count = [(@pre_national_market_percent / 20).to_i, shares_left_to_distribute].min
          shares_left_to_distribute -= national_market_share_count
          # More than 10 shares were issued so issue the second set
          national_issue_shares! if shares_left_to_distribute < 10
          national_share_index = 1
          players_in_order.each do |i|
            player = @players[i]
            next unless @pre_national_percent_by_player[player]

            player_national_shares = (@pre_national_percent_by_player[player] / 20).to_i
            # We will distribute shares from the national starting with the second, skipping the presidency
            next unless player_national_shares.positive?

            if player == president
              if @false_national_president
                # TODO: Handle this case properly.
                @log << "#{player.name} is the president of the #{national.name} but is only awarded 1 share}"
                national.presidents_share.percent /= 2
                @share_pool.buy_shares(player, national.presidents_share, exchange: :free, exchange_price: 0)
                player_national_shares -= 1
              else # This player gets the presidency, which is 2 shares
                @share_pool.buy_shares(player, national.presidents_share, exchange: :free, exchange_price: 0)
                player_national_shares -= 2
              end
            end
            # not president, just give them shares
            while player_national_shares.positive?
              if national_share_index == (max_national_shares - 1) # 19 shares; president is double
                @log << "#{national.name} is out of shares to issue, #{player.name} gets no more shares"
                player_national_shares = 0
              else
                @share_pool.buy_shares(
                  player,
                  national.shares_by_corporation[national].last,
                  exchange: :free,
                  exchange_price: 0
                )
                player_national_shares -= 1
                national_share_index += 1
              end
            end
          end
          # Distribute market shares to the market
          return unless national_market_share_count.positive?

          @share_pool.buy_shares(
            @share_pool,
            ShareBundle.new(national.shares_by_corporation[national][-1 * national_market_share_count..-1]),
            exchange: :free
          )
        end

        def national_token_swap
          # Token swap
          # The CGR has ten station markers. Up to ten station markers of the absorbed companies are exchanged
          # for CGR tokens. All home station markers must be replaced first. Then the other station markers are
          # replaced in whatever order the president chooses. Because the CGR cannot have two or more station
          # markers on the same tile, the president of the CGR may choose which one to use, except that
          # exchanging a company's home station marker must take precedence. All station markers that can
          # be legally exchanged must be, even if the president would rather not do so. Further station
          # markers may be placed during operating rounds at a cost of $100 each.

          # Homes first, those are mandatory
          # The case where all 11 corporations are nationalized is undefined behavior in the rules;
          #  The national only has 10 tokens but home tokens are mandatory. This is exceedingly bad play
          #  so it shouldn't ever happen..
          home_bases = @nationalized_corps.map do |c|
            nationalize_home_token(c, create_national_token)
          end

          # Other tokens second, ignoring duplicates from the home token set
          @nationalized_corps.each do |corp|
            corp.tokens.each do |token|
              next if !token.used || !token.city || home_bases.include?(token.city.hex)

              remove_duplicate_tokens(corp)
              replace_token(corp, token, create_national_token)
            end
          end

          # Then reduce down to limit
          # TODO: Possibly override ReduceTokens?
          tokens_to_keep = [home_bases.size, national_token_limit].max
          if national.tokens.size > tokens_to_keep
            @log << "#{national.name} is above token limit and must decide which tokens to remove"
            # This will be resolved in RemoveTokens
            @round.pending_removals << {
              corp: national,
              count: national.tokens.size - tokens_to_keep,
              hexes: national.tokens.map(&:hex).reject { |hex| home_bases.include?(hex) },
            }
          end
          remaining_tokens = [tokens_to_keep - national.tokens.size, 0].max
          @log << "#{national.name} has #{remaining_tokens} spare #{format_currency(national_token_price)} tokens"
          remaining_tokens.times { national.tokens << Engine::Token.new(@national, price: national_token_price) }
        end

        def declare_bankrupt(player)
          @bankrupted = true
          super
        end

        # Called regardless of if president saved or merged corp
        def post_corp_nationalization
          return unless nationalizables.empty?

          unless @national_formed
            @log << "#{national.name} does not form"
            national.close!
            return
          end
          float_national
          national_share_swap
          # Now that shares and president are determined, it's time to do presidential things
          national_token_swap
          # Close corporations now that trains, cash, rights, and tokens have been stripped
          @nationalized_corps.each do |c|
            close_corporation(c)
            # close_corporation does not close the corp from continuing acting in the round so we need close!
            c.close!
          end

          # Reduce the nationals train holding limit to the real value
          # (It was artificially high to avoid forced discard triggering early)
          @nationalization_train_discard_trigger = true
          @post_nationalization = true
        end

        # Creates and returns a token for the national
        def create_national_token
          token = Engine::Token.new(national, price: national_token_price)
          national.tokens << token
          token
        end

        def remove_duplicate_tokens(corp)
          # If there are 2 station markers on the same city the
          # surviving company must remove one and place it on its charter.
          # In the case of OO and Toronto tiles this is ambigious and must be solved by the user

          cities = Array(corp).flat_map(&:tokens).map(&:city).compact
          @national.tokens.select { |t| cities.include?(t.city) }.each(&:destroy!)
        end

        # Convert the home token of the corporation to one of the national's
        # Return the nationalized corps home hex
        def nationalize_home_token(corp, token)
          unless token
            # Why would this ever happen?
            @log << "#{national.name} is out of tokens and does not get a token for #{corp.name}'s home"
            return
          end
          # A nationalized corporation needs to have a loan which means it needs to have operated so it must have a home
          home_token = corp.tokens.first
          home_hex = home_token.city.hex

          replace_token(corp, home_token, token)
          home_hex
        end

        def replace_token(major, major_token, token)
          city = major_token.city
          @log << "#{major.name}'s token in #{city.hex.name} is replaced with a #{national.name} token"
          major_token.remove!
          city.place_token(national, token, check_tokenable: false)
        end

        def nationalizable_corporations
          floated_player_corps = @corporations.select { |c| c.floated? && c != national }
          floated_player_corps.select! { |c| c.loans.size.positive? }
          # Sort eligible corporations so that they are in player order
          # starting with the player that bought the 6 train
          index_for_trigger = @players.index(@nationalization_trigger)
          # This is based off the code in 18MEX; 10 appears to be an arbitrarily large integer
          #  where the exact value doesn't really matter
          order = @players.each_with_index.map { |p, i| i < index_for_trigger ? [p, i + 10] : [p, i] }.to_h
          floated_player_corps.sort_by { |c| [order[c.player], @round.entities.index(c)] }
        end

        def present_nationalizables(nationalizables)
          nationalizables.map do |c|
            "#{c.name} (#{c.player.name})"
          end.join(', ')
        end

        def nationalization_president_payoff(major, owed)
          major.spend(major.cash, @bank) if major.cash.positive?
          major.owner.spend(owed, @bank)
          @loans << major.loans.pop(major.loans.size)
          @log << "#{major.name} spends the remainder of its cash towards repaying loans"
          @log << "#{major.owner.name} pays off the #{format_currency(owed)} debt for #{major.name}"
          nationalizables.delete(major)
          post_corp_nationalization
        end

        def borrow_train(action)
          entity = action.entity
          train = action.train
          buy_train(entity, train, :free)
          @borrowed_trains[entity] = train
          @log << "#{entity.name} borrows a #{train.name}"
        end

        def train_limit(entity)
          super + Array(abilities(entity, :train_limit)).sum(&:increase)
        end
      end
    end
  end
end
