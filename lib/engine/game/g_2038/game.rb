# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G2038
      class Game < Game::Base
        include_meta(G2038::Meta)

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#ccdeee',
                        lightBlue: '#e0ebf4',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037')
        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER = :sell_buy
        CURRENCY_FORMAT_STR = '$%d'

        BANK_CASH = 10_000

        CERT_LIMIT = { 3 => 22, 4 => 16, 5 => 13, 6 => 11 }.freeze

        STARTING_CASH = { 3 => 600, 4 => 450, 5 => 360, 6 => 300 }.freeze

        TILES = {
          '70' => 1,
        }.freeze

        LOCATION_NAMES = {
          'A1' => 'MM',
          'B6' => 'Torch',
          'D8' => 'RU',
          'D14' => 'Drill Hound',
          'F18' => 'RCC',
          'G7' => 'Fast Buck',
          'H14' => 'Lucky',
          'J2' => 'VP',
          'J18' => 'OCP',
          'K9' => 'TSI',
          'M5' => 'Ore Crusher',
          'M13' => 'Ice Finder',
          'O1' => 'LE',
        }.freeze

        MARKET = [
          %w[71
             80
             90
             101
             113
             126
             140
             155
             171
             188
             206
             225
             245
             266
             288
             311
             335
             360
             386
             413
             441
             470
             500],
          %w[62
             70
             79
             89
             100p
             112
             125x
             139
             154
             170
             187
             205
             224
             244
             265
             287
             310
             334
             359
             385
             412
             440
             469],
          %w[54
             61
             69
             78
             88p
             99
             111
             124
             138
             153
             169
             186
             204
             223
             243
             264],
          %w[46
             53
             60
             68
             77p
             87
             98
             110
             123
             137
             152
             168
             185],
          %w[36
             45
             52
             59
             67p
             76
             86
             97
             109
             122
             136],
          %w[24
             35
             44
             51
             58
             66
             75
             85
             96],
          %w[10z
             23
             34
             43
             50
             57
             65],
        ].freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(par: 'Public Corps Par',
                                              par_1: 'Asteroid League Par',
                                              par_2: 'All Growth Corps Par')

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par: :grey,
                                                            par_1: :brown,
                                                            par_2: :blue)

        PHASES = [{ name: '1', train_limit: 4, tiles: [:yellow], operating_rounds: 2 },
                  {
                    name: '2',
                    on: '4dc3',
                    train_limit: 4,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: ['can_buy_companies'],
                  },
                  {
                    name: '3',
                    on: '5dc4',
                    train_limit: 3,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: ['can_buy_companies'],
                  },
                  {
                    name: '4',
                    on: '6d5c',
                    train_limit: 3,
                    tiles: %i[yellow green brown],
                    operating_rounds: 2,
                  },
                  {
                    name: '5',
                    on: '7d6c',
                    train_limit: 3,
                    tiles: %i[yellow green brown],
                    operating_rounds: 2,
                  },
                  {
                    name: '6',
                    on: '9d7c',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 2,
                  }].freeze

        TRAINS = [{
                    name: '3dc2',
                    distance: 3,
                    price: 100,
                    rusts_on: ['5dc4', '7d3c'],
                    num: 10,
                    variants: [
                      {
                        name: '5dc1',
                        rusts_on: ['5dc4', '7d3c'],
                        distance: 5,
                        price: 100,
                      },
                    ],
                  },
                  {
                    name: '4dc3',
                    distance: 4,
                    price: 200,
                    rusts_on: ['7d6c', '9d5c'],
                    num: 10,
                    variants: [
                      {
                        name: '6d2c',
                        rusts_on: ['7d6c', '9d5c'],
                        distance: 6,
                        price: 175,
                      },
                    ],
                  },
                  {
                    name: '5dc4',
                    distance: 5,
                    price: 325,
                    rusts_on: 'D',
                    num: 6,
                    variants: [
                      {
                        name: '7d3c',
                        distance: 7,
                        price: 275,
                      },
                    ],
                  },
                  {
                    name: '6d5c',
                    distance: 6,
                    price: 450,
                    num: 5,
                    variants: [
                      {
                        name: '8d4c',
                        distance: 8,
                        price: 400,
                      },
                    ],
                    events: [{ 'type' => 'close_companies' }],
                  },
                  {
                    name: '7d6c',
                    distance: 7,
                    price: 600,
                    num: 2,
                    variants: [
                      {
                        name: '9d5c',
                        distance: 9,
                        price: 550,
                      },
                    ],
                  },
                  {
                    name: '9d7c',
                    distance: 9,
                    price: 950,
                    num: 9,
                    discount: { '5dc4' => 700, '7d3c' => 700 },
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
            color: :"#474548",
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
            color: :"#ADD8E6",
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
            color: :"#FFF500",
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
            color: :"#d88e39",
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
            color: :"#95c054",
            reservation_color: nil,
          },
        ].freeze

        def to_hex_list(s, e, l)
          Range.new(s,e).step(2).map { |x| "%s%d" % [l, x] }
        end

        def game_hexes
          blue_map = [
            ['A', 3, 11],
            ['B', 2, 4],
            ['B', 8, 14],
            ['C', 1, 15],
            ['D', 4, 6],
            ['D', 10, 12],
            ['D', 16, 16],
            ['E', 3, 17],
            ['F', 2, 16],
            ['G', 3, 5],
            ['G', 9, 17],
            ['H', 4, 8],
            ['H', 12, 12],
            ['H', 16, 16],
            ['I', 3, 17],
            ['J', 4, 16],
            ['K', 3, 7],
            ['K', 11, 17],
            ['L', 2, 16],
            ['M', 1, 3],
            ['M', 7, 11],
            ['M', 15, 15],
            ['N', 2, 14],
            ['O', 3, 9],
            ['O', 13, 13],
          ]

          blue_hexes = []
          blue_map.each { |l,s,e| blue_hexes.append(to_hex_list(s,e,l)) }
          blue_hexes = blue_hexes.flatten

          hexes = {
            black: {
              %w[A13
                 D2
                 H10
                 H18
                 O11
              ] => 'blank'
            },
            grey: {
              %w[A1
                 B6
                 D8
                 D14
                 F18
                 G7
                 H14
                 J2
                 J18
                 K9
                 M5
                 M13
                 O1
              ] => 'blank'
            },
            blue: {
              blue_hexes => 'blank'
            }
          }
        end

        LAYOUT = :pointy

        def operating_round(round_num)
          Round::Operating.new(self, [
            Step::Bankrupt,
            Step::Exchange,
            Step::SpecialTrack,
            Step::SpecialToken,
            Step::BuyCompany,
            Step::HomeToken,
            Step::Track,
            Step::Token,
            Step::Route,
            Step::Dividend,
            Step::DiscardTrain,
            Step::BuyTrain,
            [Step::BuyCompany, blocks: true],
          ], round_num: round_num)
        end
      end
    end
  end
end
