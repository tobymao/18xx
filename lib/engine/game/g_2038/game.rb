# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'company'

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
        SELL_AFTER = :p_any_operate
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

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          par: :grey,
          par_1: :brown,
          par_2: :blue
        )

        PHASES = [
                  {
                    name: '1',
                    train_limit: 4,
                    tiles: [:yellow],
                    operating_rounds: 2,
                  },
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
                  },
                ].freeze

        TRAINS = [
          {
            name: 'probe',
            distance: 4,
            price: 1,
            rusts_on: %w[4dc3 6d2c],
            num: 1,
          },
          {
            name: '3dc2',
            distance: 3,
            price: 100,
            rusts_on: %w[5dc4 7d3c],
            num: 10,
            variants: [
              {
                name: '5dc1',
                rusts_on: %w[5dc4 7d3c],
                distance: 5,
                price: 100,
              },
            ],
          },
          {
            name: '4dc3',
            distance: 4,
            price: 200,
            rusts_on: %w[7d6c 9d5c],
            num: 10,
            variants: [
              {
                name: '6d2c',
                rusts_on: %w[7d6c 9d5c],
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
            discount: {
              '5dc4' => 700,
              '7d3c' => 700,
              '6d5c' => 700,
              '8d4c' => 700,
              '7d6c' => 700,
              '9d5c' => 700,
            },
          },
        ].freeze

        COMPANIES = [
          {
            name: 'Planetary Imports',
            sym: 'PI',
            value: 50,
            revenue: 10,
            desc: 'No special abilities',
            color: nil,
          },
          {
            name: 'Tunnel Systems',
            sym: 'TS',
            value: 120,
            revenue: 5,
            desc: 'Buyer recieves a TSI Share.  If owned by a corporation, may place 1 free Base on ANY'\
            'explored and unclaimed tile.',
            abilities: [{ type: 'shares', shares: 'TSI_3' },
                        {
                          type: 'tile_lay',
                          owner_type: 'corporation',
                          tiles: ['1'],
                          when: 'owning_corp_or_turn',
                          count: 1,
                        }],
            color: nil,
          },
          {
            name: 'Vacuum Associates',
            sym: 'VA',
            value: 140,
            revenue: 10,
            desc: 'Buyer recieves a TSI Share.  If owned by a corporation, may place 1 free'\
            'Refueling Station within range.',
            abilities: [{ type: 'shares', shares: 'TSI_2' },
                        {
                          type: 'tile_lay',
                          owner_type: 'corporation',
                          tiles: ['2'],
                          when: 'owning_corp_or_turn',
                          count: 1,
                        }],
            color: nil,
          },
          {
            name: 'Robot Smelters, Inc.',
            sym: 'RS',
            value: 160,
            revenue: 15,
            desc: 'Buyer recieves a TSI Share.  If owned by a corporation, may place 1 free Claim within range.',
            abilities: [{ type: 'shares', shares: 'TSI_1' },
                        {
                          type: 'tile_lay',
                          owner_type: 'corporation',
                          tiles: ['3'],
                          when: 'owning_corp_or_turn',
                          count: 1,
                        }],
            color: nil,
          },
          {
            name: 'Space Transportation Co.',
            sym: 'ST',
            value: 180,
            revenue: 20,
            desc: "Buyer recieves TSI president's Share and flies probe if TSI isn't active.  May not be owned"\
            ' by a corporation. Remove from the game after TSI buys a spaceship.',
            abilities: [{ type: 'shares', shares: 'TSI_0' },
                        { type: 'no_buy' },
                        { type: 'close', when: 'bought_train', corporation: 'TSI' }],
            color: nil,
          },
          {
            name: 'Asteroid Export Co.',
            sym: 'AE',
            value: 180,
            revenue: 30,
            desc: "Forms Asteroid League, receiving its President's certificate.  May not be bought by a"\
            ' corporation.  Remove from the game after AL aquires a spaceship.',
            abilities: [{ type: 'close', when: 'bought_train', corporation: 'AL' },
                        { type: 'no_buy' },
                        {
                          type: 'shares',
                          shares: 'AL_0',
                          when: ['Phase 3', 'Phase 4'],
                        }],
            color: nil,
          },
        ].freeze

        MINORS = [
          {
            sym: 'FB',
            name: 'Fast Buck',
            value: 100,
            coordinates: 'G7',
            logo: '18_eu/1',
            tokens: [60, 100],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[RU VP MM LE OPC RCC AL],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: 'IF',
            name: 'Ice Finder',
            value: 100,
            coordinates: 'G7',
            logo: '18_eu/2',
            tokens: [60, 100],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[RU VP MM LE OPC RCC AL],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: 'DH',
            name: 'Drill Hound',
            value: 100,
            coordinates: 'D14',
            logo: '18_eu/3',
            tokens: [60, 100],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[RU VP MM LE OPC RCC AL],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: 'OC',
            name: 'Ore Crusher',
            value: 100,
            coordinates: 'M5',
            logo: '18_eu/4',
            tokens: [60, 100],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[RU VP MM LE OPC RCC AL],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: 'TT',
            name: 'Torch',
            value: 100,
            coordinates: 'B6',
            logo: '18_eu/5',
            tokens: [60, 100],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[RU VP MM LE OPC RCC AL],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
          {
            sym: 'LY',
            name: 'Lucky',
            value: 100,
            coordinates: 'H14',
            logo: '18_eu/6',
            tokens: [60, 100],
            color: 'black',
            text_color: 'white',
            abilities: [
              {
                type: 'exchange',
                corporations: %w[RU VP MM LE OPC RCC AL],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 50,
            sym: 'TSI',
            name: 'Trans-Space Incorporated',
            logo: '18_chesapeake/PRR',
            simple_logo: '1830/PRR.alt',
            tokens: [60, 100, 60, 100, 60, 100, 60, 100, 60, 100],
            coordinates: 'K9',
            color: '#32763f',
            type: 'groupA',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'RU',
            name: 'Resources Unlimited',
            logo: '18_chesapeake/PRR',
            simple_logo: '1830/PRR.alt',
            tokens: [0, 100, 0, 100, 0, 100, 0, 100, 0, 100, 0, 100],
            coordinates: 'D8',
            color: '#32763f',
            type: 'groupA',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'VP',
            name: 'Venus Prospectors Limited',
            logo: '1830/NYC',
            simple_logo: '1830/NYC.alt',
            tokens: [60, 100, 60, 100, 60],
            coordinates: 'J1',
            color: :"#474548",
            type: 'groupB',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'LE',
            name: 'Lunar Enterprises',
            logo: '1830/CPR',
            simple_logo: '1830/CPR.alt',
            tokens: [60, 100, 60, 100, 60, 100, 60, 100, 60],
            coordinates: 'O1',
            color: '#d1232a',
            type: 'groupB',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'MM',
            name: 'Mars Mining',
            logo: '18_chesapeake/BO',
            simple_logo: '1830/BO.alt',
            tokens: [60, 100, 60, 100, 60, 100],
            coordinates: 'A1',
            color: '#025aaa',
            type: 'groupB',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'OPC',
            name: 'Outer Planet Consortium',
            logo: '18_chesapeake/CO',
            simple_logo: '1830/CO.alt',
            tokens: [60, 100, 60, 100, 60, 100, 60],
            coordinates: 'J18',
            color: :"#ADD8E6",
            text_color: 'black',
            type: 'groupC',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'RCC',
            name: 'Ring Construction Corporation',
            logo: '1846/ERIE',
            simple_logo: '1830/ERIE.alt',
            tokens: [60, 100, 60, 100, 60, 100, 60, 100],
            coordinates: 'F18',
            color: :"#FFF500",
            text_color: 'black',
            type: 'groupC',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'AL',
            name: 'Asteroid League',
            logo: '1830/NYNH',
            simple_logo: '1830/NYNH.alt',
            tokens: [60, 75, 100, 60, 75, 100, 60, 75, 100, 60, 75, 100, 60, 75, 100],
            coordinates: 'H10',
            color: :"#d88e39",
            type: 'groupD',
            reservation_color: nil,
          },
        ].freeze

        # Overrides

        def to_hex_list(s, e, l)
          Range.new(s, e).step(2).map { |x| "#{l}#{x}" }
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
          blue_map.each { |l, s, e| blue_hexes.append(to_hex_list(s, e, l)) }
          blue_hexes = blue_hexes.flatten

          {
            black: {
              %w[A13
                 D2
                 H10
                 H18
                 O11] => '',
            },
            gray: {
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
                 O1] => '',
            },
            blue: {
              blue_hexes => '',
            },
          }
        end

        def company_header(company)
          is_minor = @minors.find { |m| m.id == company.id }

          if is_minor
            'INDEPENDENT COMPANY'
          else
            'PRIVATE COMPANY'
          end
        end

        def init_companies(players)
          companies = super(players)

          wrapped_companies = game_minors.map { |minor| G2038::Company.new(minor) }
          companies + wrapped_companies
        end

        # def init_corporations(stock_market)
        #  min_price = stock_market.par_prices.map(&:price).min

        #  game_corporations.map do |corporation|
        #    next unless corporation[:type] == 'groupA'

        #    G2038::Corporation.new(
        #      self,
        #      min_price: min_price,
        #      capitalization: nil,
        #      **corporation.merge(corporation_opts),
        #    )
        #  end
        # end

        LAYOUT = :pointy

        def new_auction_round
          Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            G2038::Step::WaterfallAuction,
          ])
        end
      end
    end
  end
end
