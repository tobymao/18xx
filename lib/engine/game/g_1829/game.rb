# frozen_string_literal: true

# todos
# upgrade tile 3,4,1,2,55 to 12,13,14,15
# graybrown tile
# foreign tokened cities do not count for dividends
# survey party implentation
# steamship
# close privates voluntary
# fixed par price and fixed order in OR

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G1829
      class Game < Game::Base
        include_meta(G1829::Meta)

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
        CURRENCY_FORMAT_STR = '$%dP'
        GAME_END_CHECK = { bank: :immediate }.freeze

        BANK_CASH = 20_000

        CERT_LIMIT = { 3 => 18, 4 => 18, 5 => 17, 6 => 14, 7 => 12, 8 => 10, 9 => 9 }.freeze

        STARTING_CASH = { 3 => 840, 4 => 630, 5 => 1504, 6 => 420, 7 => 360, 8 => 315, 9 => 280 }.freeze

        TILES = {
          '1' => 2,
          '2' => 2,
          '3' => 2,
          '4' => 6,
          '5' => 4,
          '6' => 4,
          '7' => 4,
          '8' => 8,
          '9' => 10,
          '10' => 3,
          '11s' => 2,
          '12' => 3,
          '13' => 3,
          '14' => 3,
          '15' => 3,
          '16' => 1,
          '17' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '21' => 1,
          '22' => 1,
          '23' => 4,
          '24' => 4,
          '25' => 2,
          '26' => 2,
          '27' => 2,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '32' => 1,
          '33s' => 1,
          '34' => 1,
          '35' => 1,
          '36' => 1,
          '37s' => 1,
          '38' => 6,
          '39' => 1,
          '40' => 1,
          '41' => 2,
          '42' => 2,
          '43' => 1,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 1,
          '48' => 1,
          '49' => 1,
          '50s' => 1,
          '51' => 1,
          '55' => 2,
          '59s' => 2,
          '60' => 2,
        }.freeze

        LOCATION_NAMES = {
        }.freeze

        MARKET = [
          %w[0c 10y
             20y
             29y
             38
             47
             53
             56p
             58p
             61p
             64p
             67p
             71p
             76p
             82p
             90p
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
             320
             335
             345
             350],
        ].freeze
        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          init1: :red,
          init2: :green,
          init3: :orange,
          init4: :brightgreen,
          init5: :lightblue,
          init6: :yellow,
          init7: :orange,
          init8: :red,
          init9: :blue,
          init10: :orange,
        ).freeze

        PAR_RANGE = {
          init1: [100],
          init2: [90],
          init3: [82],
          init4: [76],
          init5: [71],
          init6: [67],
          init7: [64],
          init8: [61],
          init9: [58],
          init10: [56],
        }.freeze

        MARKET_TEXT = {
          init1: 'Startkurs LNWR',
          init2: 'Startkurs GWR',
          init3: 'Startkurs Midland',
          init4: 'Startkurs LSWR',
          init5: 'Startkurs GNR',
          init6: 'Startkurs LBSC',
          init7: 'Startkurs GER',
          init8: 'Startkurs GCR',
          init9: 'Startkurs L&YR',
          init10: 'Startkurs SECR',
        }.freeze

        PHASES = [{ name: '2', train_limit: 4, tiles: [:yellow], operating_rounds: 1 },
                  {
                    name: '3',
                    on: '3',
                    train_limit: 4,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                  },
                  {
                    name: '5',
                    on: '5',
                    train_limit: 3,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: '7',
                    on: '7',
                    train_limit: 2,
                    tiles: %i[yellow green brown gray],
                    operating_rounds: 4,
                    status: ['Private Companies are closed'],
                  }].freeze

        TRAINS = [{ name: '2', distance: 2, price: 180, rusts_on: '5', num: 7 },
                  { name: '3', distance: 3, price: 300, rusts_on: '7', num: 6 },
                  { name: '4', distance: 4, price: 430, num: 5 },
                  {
                    name: '5',
                    distance: 5,
                    price: 450,
                    num: 5,
                  },
                  {
                    name: '7',
                    distance: 7,
                    price: 720,
                    num: 4,
                    events: [{ 'type' => 'close_companies' }, { 'type' => 'private' }],
                  }].freeze

        COMPANIES = [
          {
            name: 'Swansea & Mumbles',
            sym: 'SM',
            value: 30,
            type: 'private',
            revenue: 5,
            desc: 'No special abilities.',
            color: nil,
          },
          {
            name: 'Cromford & High Peak',
            sym: 'CH',
            value: 75,
            type: 'private',
            revenue: 10,
            desc: 'Blocks D11, while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['D11'] }],
            color: nil,
          },
          {
            name: 'Canterbury & Whitstable',
            sym: 'CW',
            type: 'private',
            value: 130,
            revenue: 15,
            desc: 'Blocks K22, while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['K22'] }],
            color: nil,
          },
          {
            name: 'Liverpool & Manchester',
            sym: 'LM',
            value: 210,
            type: 'private',
            revenue: 20,
            desc: 'Blocks Liverpool (C6,C8), while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[C6 C8] }],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'LNWR',
            name: 'London & North Western',
            logo: '1822/LNWR',
            simple_logo: '1829/LNWR.alt',
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'E8',
            type: 'init1',
            color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'GWR',
            name: 'Great Western',
            logo: '1822/GWR',
            simple_logo: '1829/GWR.alt',
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'J11',
            type: 'init2',
            color: 'darkgreen',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'Mid',
            name: 'Midland',
            logo: '1822/MR',
            simple_logo: '1829/MR.alt',
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'E12',
            color: 'red',
            type: 'init3',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'LSWR',
            name: 'London & South Western',
            logo: '1822/5',
            simple_logo: '1829/LSWR.alt',
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'J17',
            city: 0,
            type: 'init4',
            color: 'lightgreen',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'GNR',
            name: 'Great Northern',
            logo: '1822/6',
            simple_logo: '1829/GNR.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'C14',
            color: 'blue',
            type: 'init5',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'LBSC',
            name: 'LBSC',
            logo: '1822/LBSCR',
            simple_logo: '1829/LBSC.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'L17',
            color: 'buff',
            type: 'init6',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'GER',
            name: 'Great Eastern',
            logo: '1822/7',
            simple_logo: '1829/GER.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'J17',
            city: 2,
            type: 'init7',
            color: 'darkblue',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'GCR',
            name: 'Great Central',
            logo: '1822/8',
            simple_logo: '1829/GCR.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'C12',
            type: 'init8',
            color: 'lightblue',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'LYR',
            name: 'Lancashire & Yorkshire',
            logo: '1822/LYR',
            simple_logo: '1822/LYR.alt',
            tokens: [0, 40, 100],
            coordinates: 'C8',
            city: 1,
            type: 'init9',
            color: 'brown',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'SECR',
            name: 'South Eastern & Chatham',
            logo: '1822/SECR',
            simple_logo: '1822/SECR.alt',
            tokens: [0, 40, 100],
            coordinates: 'L21',
            type: 'init10',
            color: :"#ADD8E6",
            text_color: 'yellow',
            reservation_color: nil,
          },
        ].freeze

        HEXES = {
          white: {
            %w[B7] => 'city=revenue:0;upgrade=cost:40,terrain:water',
            %w[D15 E2 E10 F7 F13 H13 H17 H21 I18 J13 K20] => 'town',
            %w[D17
               E6
               E16
               F3
               F5
               F11
               F15
               F19
               G6
               G8
               G14
               G16
               G18
               G20
               G22
               H1
               H7
               H9
               H11
               H15
               H19
               I2
               I6
               I10
               I12
               I14
               I16
               I20
               J9
               J15
               K10
               K12
               K14
               K18
               L1
               L5
               L7
               L9
               L15
               L19
               M2
               M6
               M8] => 'blank',
            %w[L3 H3 H5 G4 E4 D9 D11 C10] =>
            'upgrade=cost:160,terrain:mountain',
            %w[C12 E12 E14 F21 G12 J5 K22 L17 L11 M4] => 'city',
            ['B9'] => 'town=revenue:0;town=revenue:0;upgrade=cost:160,terrain:mountain',
            %w[F17 I4 K8 K16] => 'town=revenue:0;town=revenue:0',
            %w[I8] => 'town=revenue:0;upgrade=cost:40,terrain:water',
            %w[B13 B15 C16 D3 D7] => 'upgrade=cost:40,terrain:water',
          },
          yellow: {
            %w[J7] =>
                     'city=revenue:0;city=revenue:0;label=OO;upgrade=cost:40,terrain:water',
            %w[L13 F9 D13 B11] => 'city=revenue:0;city=revenue:0;label=OO',
          },
          green: {
            ['C6'] => 'city=revenue:40;city=revenue:40;path=a:5,b:_0;path=a:3,b:_1;label=L',
            ['C8'] => 'city=revenue:40;city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2
                      ;label=BGM',
            ['G10'] => 'city=revenue:40;city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:3,b:_1;path=a:5,b:_2
                       ;label=BGM',
            ['J17'] => 'city=revenue:50;city=revenue:50;city=revenue:50;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2
                       ;upgrade=cost:40,terrain:water;label=LD',
          },
          brown: {
            ['A6'] => 'path=a:4,b:5',
            ['A8'] => 'path=a:4,b:1;path=a:0,b:5',
            ['A10'] => 'path=a:1,b:5;path=a:0,b:4',
            ['A12'] => 'city=revenue:30;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['A14'] => 'path=a:1,b:5',
            ['B17'] => 'city=revenue:20;path=a:1,b:_0;label=Hull',
            ['C14'] => 'city=revenue:20;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            ['D1'] => 'city=revenue:20;path=a:5,b:_0;path=a:4,b:_0;label=Holyhead',
            ['D5'] => 'path=a:1,b:4;path=a:1,b:5',
            ['E8'] => 'city=revenue:10;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            ['F23'] => 'town=revenue:10;path=a:1,b:_0;path=b:_0,a:0',
            ['G2'] => 'town=revenue:10;path=a:0,b:_0;path=b:_0,a:3',
            ['I22'] => 'city=revenue:20;path=a:1,b:_0;path=a:2,b:_0;label=Harwich',
            ['J3'] => 'city=revenue:20;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=S&M',
            ['J11'] => 'city=revenue:10;path=a:1,b:_0;path=a:2,b:_0;path=a:0,b:_0;path=a:4,b:_0',
            ['J19'] => 'city=revenue:20;path=a:1,b:_0;path=a:2,b:_0;path=a:1,b:2',
            ['K6'] => 'path=a:0,b:3;path=a:0,b:4',
            ['L21'] => 'city=revenue:10;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            ['M10'] => 'city=revenue:20;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            ['M18'] => 'path=a:2,b:3',
            ['N1'] => 'city=revenue:30;path=a:3,b:_0;path=a:4,b:_0',
            ['N3'] => 'path=a:1,b:3',
          },
        }.freeze

        LAYOUT = :pointy

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::CloseCompany,
            Engine::Step::Exchange,
            Engine::Step::HomeToken,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: false }],
          ], round_num: round_num)
        end
      end
    end
  end
end
