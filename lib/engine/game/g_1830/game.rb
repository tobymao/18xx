# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G1830
      class Game < Game::Base
        include_meta(G1830::Meta)

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        lightBlue: '#8dd7f6',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037')
        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER = :sell_buy_sell
        TILE_RESERVATION_BLOCKS_OTHERS = :always
        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 12_000

        CERT_LIMIT = { 2 => 28, 3 => 20, 4 => 16, 5 => 13, 6 => 11 }.freeze

        STARTING_CASH = { 2 => 1200, 3 => 800, 4 => 600, 5 => 480, 6 => 400 }.freeze

        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 2,
          '4' => 2,
          '7' => 4,
          '8' => 8,
          '9' => 7,
          '14' => 3,
          '15' => 2,
          '16' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 3,
          '24' => 3,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 1,
          '53' => 2,
          '54' => 1,
          '55' => 1,
          '56' => 1,
          '57' => 4,
          '58' => 2,
          '59' => 2,
          '61' => 2,
          '62' => 1,
          '63' => 3,
          '64' => 1,
          '65' => 1,
          '66' => 1,
          '67' => 1,
          '68' => 1,
          '69' => 1,
          '70' => 1,
        }.freeze

        LOCATION_NAMES = {
          'D2' => 'Lansing',
          'F2' => 'Chicago',
          'J2' => 'Gulf',
          'F4' => 'Toledo',
          'J14' => 'Washington',
          'F22' => 'Providence',
          'E5' => 'Detroit & Windsor',
          'D10' => 'Hamilton & Toronto',
          'F6' => 'Cleveland',
          'E7' => 'London',
          'A11' => 'Canadian West',
          'K13' => 'Deep South',
          'E11' => 'Dunkirk & Buffalo',
          'H12' => 'Altoona',
          'D14' => 'Rochester',
          'C15' => 'Kingston',
          'I15' => 'Baltimore',
          'K15' => 'Richmond',
          'B16' => 'Ottawa',
          'F16' => 'Scranton',
          'H18' => 'Philadelphia & Trenton',
          'A19' => 'Montreal',
          'E19' => 'Albany',
          'G19' => 'New York & Newark',
          'I19' => 'Atlantic City',
          'F24' => 'Mansfield',
          'B20' => 'Burlington',
          'E23' => 'Boston',
          'B24' => 'Maritime Provinces',
          'D4' => 'Flint',
          'F10' => 'Erie',
          'G7' => 'Akron & Canton',
          'G17' => 'Reading & Allentown',
          'F20' => 'New Haven & Hartford',
          'H4' => 'Columbus',
          'B10' => 'Barrie',
          'H10' => 'Pittsburgh',
          'H16' => 'Lancaster',
        }.freeze

        MARKET = [
          %w[60y
             67
             71
             76
             82
             90
             100p
             112
             126
             142
             160
             180
             200
             225
             250
             275
             300
             325
             350],
          %w[53y
             60y
             66
             70
             76
             82
             90p
             100
             112
             126
             142
             160
             180
             200
             220
             240
             260
             280
             300],
          %w[46y
             55y
             60y
             65
             70
             76
             82p
             90
             100
             111
             125
             140
             155
             170
             185
             200],
          %w[39o
             48y
             54y
             60y
             66
             71
             76p
             82
             90
             100
             110
             120
             130],
          %w[32o 41o 48y 55y 62 67 71p 76 82 90 100],
          %w[25b 34o 42o 50y 58y 65 67p 71 75 80],
          %w[18b 27b 36o 45o 54y 63 67 69 70],
          %w[10b 20b 30b 40o 50y 60y 67 68],
          ['', '10b', '20b', '30b', '40o', '50y', '60y'],
          ['', '', '10b', '20b', '30b', '40o', '50y'],
          ['', '', '', '10b', '20b', '30b', '40o'],
        ].freeze

        PHASES = [{ name: '2', train_limit: 4, tiles: [:yellow], operating_rounds: 1 },
                  {
                    name: '3',
                    on: '3',
                    train_limit: 4,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: ['can_buy_companies'],
                  },
                  {
                    name: '4',
                    on: '4',
                    train_limit: 3,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: ['can_buy_companies'],
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
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: 'D',
                    on: 'D',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  }].freeze

        TRAINS = [{ name: '2', distance: 2, price: 80, rusts_on: '4', num: 6 },
                  { name: '3', distance: 3, price: 180, rusts_on: '6', num: 5 },
                  { name: '4', distance: 4, price: 300, rusts_on: 'D', num: 4 },
                  {
                    name: '5',
                    distance: 5,
                    price: 450,
                    num: 3,
                    events: [{ 'type' => 'close_companies' }],
                  },
                  { name: '6', distance: 6, price: 630, num: 2 },
                  {
                    name: 'D',
                    distance: 999,
                    price: 1100,
                    num: 20,
                    available_on: '6',
                    discount: { '4' => 300, '5' => 300, '6' => 300 },
                  }].freeze

        COMPANIES = [
          {
            name: 'Schuylkill Valley',
            sym: 'SV',
            value: 20,
            revenue: 5,
            desc: 'No special abilities. Blocks G15 while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['G15'] }],
            color: nil,
          },
          {
            name: 'Champlain & St.Lawrence',
            sym: 'CS',
            value: 40,
            revenue: 10,
            desc: "A corporation owning the CS may lay a tile on the CS's hex even if this hex is not connected"\
                  " to the corporation's track. This free tile placement is in addition to the corporation's normal tile"\
                  ' placement. Blocks B20 while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['B20'] },
                        {
                          type: 'tile_lay',
                          owner_type: 'corporation',
                          hexes: ['B20'],
                          tiles: %w[3 4 58],
                          when: 'owning_corp_or_turn',
                          count: 1,
                        }],
            color: nil,
          },
          {
            name: 'Delaware & Hudson',
            sym: 'DH',
            value: 70,
            revenue: 15,
            desc: 'A corporation owning the DH may place a tile and station token in the DH hex F16 for only the $120'\
                  " cost of the mountain. The station does not have to be connected to the remainder of the corporation's"\
                  " route. The tile laid is the owning corporation's"\
                  ' one tile placement for the turn. Blocks F16 while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['F16'] },
                        {
                          type: 'teleport',
                          owner_type: 'corporation',
                          tiles: ['57'],
                          hexes: ['F16'],
                        }],
            color: nil,
          },
          {
            name: 'Mohawk & Hudson',
            sym: 'MH',
            value: 110,
            revenue: 20,
            desc: 'A player owning the MH may exchange it for a 10% share of the NYC if they do not already hold 60%'\
                  ' of the NYC and there is NYC stock available in the Bank or the Pool. The exchange may be made during'\
                  " the player's turn of a stock round or between the turns of other players or corporations in either "\
                  'stock or operating rounds. This action closes the MH. Blocks D18 while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['D18'] },
                        {
                          type: 'exchange',
                          corporations: ['NYC'],
                          owner_type: 'player',
                          when: 'any',
                          from: %w[ipo market],
                        }],
            color: nil,
          },
          {
            name: 'Camden & Amboy',
            sym: 'CA',
            value: 160,
            revenue: 25,
            desc: 'The initial purchaser of the CA immediately receives a 10% share of PRR stock without further'\
                  ' payment. This action does not close the CA. The PRR corporation will not be running at this point,'\
                  ' but the stock may be retained or sold subject to the ordinary rules of the game.'\
                  ' Blocks H18 while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['H18'] },
                        { type: 'shares', shares: 'PRR_1' }],
            color: nil,
          },
          {
            name: 'Baltimore & Ohio',
            sym: 'BO',
            value: 220,
            revenue: 30,
            desc: "The owner of the BO private company immediately receives the President's certificate of the"\
                  ' B&O without further payment. The BO private company may not be sold to any corporation, and does'\
                  ' not exchange hands if the owning player loses the Presidency of the B&O.'\
                  ' When the B&O purchases its first train the private company is closed.'\
                  ' Blocks I13 & I15 while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[I13 I15] },
                        { type: 'close', when: 'bought_train', corporation: 'B&O' },
                        { type: 'no_buy' },
                        { type: 'shares', shares: 'B&O_0' }],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'PRR',
            name: 'Pennsylvania Railroad',
            logo: '18_chesapeake/PRR',
            simple_logo: '1830/PRR.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'H12',
            color: '#32763f',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'NYC',
            name: 'New York Central Railroad',
            logo: '1830/NYC',
            simple_logo: '1830/NYC.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'E19',
            color: :'#474548',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'CPR',
            name: 'Canadian Pacific Railroad',
            logo: '1830/CPR',
            simple_logo: '1830/CPR.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'A19',
            color: '#d1232a',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'B&O',
            name: 'Baltimore & Ohio Railroad',
            logo: '18_chesapeake/BO',
            simple_logo: '1830/BO.alt',
            tokens: [0, 40, 100],
            coordinates: 'I15',
            color: '#025aaa',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'C&O',
            name: 'Chesapeake & Ohio Railroad',
            logo: '18_chesapeake/CO',
            simple_logo: '1830/CO.alt',
            tokens: [0, 40, 100],
            coordinates: 'F6',
            color: :'#ADD8E6',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'ERIE',
            name: 'Erie Railroad',
            logo: '1846/ERIE',
            simple_logo: '1830/ERIE.alt',
            tokens: [0, 40, 100],
            coordinates: 'E11',
            color: :'#FFF500',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'NYNH',
            name: 'New York, New Haven & Hartford Railroad',
            logo: '1830/NYNH',
            simple_logo: '1830/NYNH.alt',
            tokens: [0, 40],
            coordinates: 'G19',
            city: 0,
            color: :'#d88e39',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'B&M',
            name: 'Boston & Maine Railroad',
            logo: '1830/BM',
            simple_logo: '1830/BM.alt',
            tokens: [0, 40],
            coordinates: 'E23',
            color: :'#95c054',
            reservation_color: nil,
          },
        ].freeze

        HEXES = {
          red: {
            ['F2'] =>
                     'offboard=revenue:yellow_40|brown_70;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['I1'] =>
                   'offboard=revenue:yellow_30|brown_60,hide:1,groups:Gulf;path=a:4,b:_0;border=edge:5',
            ['J2'] =>
                   'offboard=revenue:yellow_30|brown_60;path=a:3,b:_0;path=a:4,b:_0;border=edge:2',
            ['A9'] =>
                   'offboard=revenue:yellow_30|brown_50,hide:1,groups:Canada;path=a:5,b:_0;border=edge:4',
            ['A11'] =>
                   'offboard=revenue:yellow_30|brown_50,groups:Canada;path=a:5,b:_0;path=a:0,b:_0;border=edge:1',
            ['K13'] => 'offboard=revenue:yellow_30|brown_40;path=a:2,b:_0;path=a:3,b:_0',
            ['B24'] => 'offboard=revenue:yellow_20|brown_30;path=a:1,b:_0;path=a:0,b:_0',
          },
          gray: {
            ['D2'] => 'city=revenue:20;path=a:5,b:_0;path=a:4,b:_0',
            ['F6'] => 'city=revenue:30;path=a:5,b:_0;path=a:0,b:_0',
            ['E9'] => 'path=a:2,b:3',
            ['H12'] => 'city=revenue:10,loc:2.5;path=a:1,b:_0;path=a:4,b:_0;path=a:1,b:4',
            ['D14'] => 'city=revenue:20;path=a:1,b:_0;path=a:4,b:_0;path=a:0,b:_0',
            ['C15'] => 'town=revenue:10;path=a:1,b:_0;path=a:3,b:_0',
            ['K15'] => 'city=revenue:20;path=a:2,b:_0',
            ['A17'] => 'path=a:0,b:5',
            ['A19'] => 'city=revenue:40;path=a:5,b:_0;path=a:0,b:_0',
            %w[I19 F24] => 'town=revenue:10;path=a:1,b:_0;path=a:2,b:_0',
            ['D24'] => 'path=a:1,b:0',
          },
          white: {
            %w[F4 J14 F22] => 'city=revenue:0;upgrade=cost:80,terrain:water',
            ['E7'] => 'town=revenue:0;border=edge:5,type:impassable',
            ['F8'] => 'border=edge:2,type:impassable',
            ['C11'] => 'border=edge:5,type:impassable',
            ['C13'] => 'border=edge:0,type:impassable',
            ['D12'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable',
            ['B16'] => 'city=revenue:0;border=edge:5,type:impassable',
            ['C17'] => 'upgrade=cost:120,terrain:mountain;border=edge:2,type:impassable',
            %w[B20 D4 F10] => 'town',
            %w[I13
               D18
               B12
               B14
               B22
               C7
               C9
               C23
               D8
               D16
               D20
               E3
               E13
               E15
               F12
               F14
               F18
               G3
               G5
               G9
               G11
               H2
               H6
               H8
               H14
               I3
               I5
               I7
               I9
               J4
               J6
               J8] => 'blank',
            %w[G15 C21 D22 E17 E21 G13 I11 J10 J12] =>
            'upgrade=cost:120,terrain:mountain',
            %w[E19 H4 B10 H10 H16] => 'city',
            ['F16'] => 'city=revenue:0;upgrade=cost:120,terrain:mountain',
            %w[G7 G17 F20] => 'town=revenue:0;town=revenue:0',
            %w[D6 I17 B18 C19] => 'upgrade=cost:80,terrain:water',
          },
          yellow: {
            %w[E5 D10] =>
                     'city=revenue:0;city=revenue:0;label=OO;upgrade=cost:80,terrain:water',
            %w[E11 H18] => 'city=revenue:0;city=revenue:0;label=OO',
            ['I15'] => 'city=revenue:30;path=a:4,b:_0;path=a:0,b:_0;label=B',
            ['G19'] =>
            'city=revenue:40;city=revenue:40;path=a:3,b:_0;path=a:0,b:_1;label=NY;upgrade=cost:80,terrain:water',
            ['E23'] => 'city=revenue:30;path=a:3,b:_0;path=a:5,b:_0;label=B',
          },
        }.freeze

        LAYOUT = :pointy

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def multiple_buy_only_from_market?
          !optional_rules&.include?(:multiple_brown_from_ipo)
        end
      end
    end
  end
end
