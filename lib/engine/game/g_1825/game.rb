# frozen_string_literal: true

# TODO list for 1825.
# (working on unit 3 to start)
# map - done
# map labels - done
# tileset
# weird promotion rules
# trains
# phases
# companies + minors
# market - done
# minor floating rules (train value)
# share price movemennt
#
# PHASE 2.
# Unit 2, with options for choosing which units you play with.



require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G1825
      class Game < Game::Base
        include_meta(G1825::Meta)

        register_colors(black: '#37383a',
                        seRed: '#f72d2d',
                        bePurple: '#2d0047',
                        peBlack: '#000',
                        beBlue: '#c3deeb',
                        heGreen: '#78c292',
                        oegray: '#6e6966',
                        weYellow: '#ebff45',
                        beBrown: '#54230e',
                        gray: '#6e6966',
                        red: '#d81e3e',
                        turquoise: '#00a993',
                        blue: '#0189d1',
                        brown: '#7b352a')

        CURRENCY_FORMAT_STR = '%dM'

        BANK_CASH = 12_000

        CERT_LIMIT = { 3 => 19, 4 => 15, 5 => 12, 6 => 11, 7 => 9 }.freeze

        STARTING_CASH = { 3 => 600, 4 => 475, 5 => 390, 6 => 340, 7 => 310 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 2,
        }.freeze

        MARKET = [
          %w[0c
             5
             10
             16
             24
             34
             42
             49
             55
             61
             67
             71
             76
             82
             90
             100
             112
             126
             142
             160
             180
             205
             230
             255
             280
             300
             320
             340],
        ].freeze

        PHASES = [
          {
            name: '1.1',
            on: '2',
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '1.2',
            on: '2+2',
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '2.1',
            on: '3',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '2.2',
            on: '3+3',
            train_limit: { major: 4, minor: 2 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '2.3',
            on: '4',
            train_limit: { major: 3, minor: 1 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '2.4',
            on: '4+4',
            train_limit: { prussian: 4, major: 3, minor: 1 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '3.1',
            on: '5',
            train_limit: { prussian: 4, major: 3, minor: 1 },
            tiles: %i[yellow green],
            operating_rounds: 3,
            events: { close_companies: true },
          },
          {
            name: '3.2',
            on: '5+5',
            train_limit: { prussian: 3, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '3.3',
            on: '6',
            train_limit: { prussian: 3, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '3.4',
            on: '6+6',
            train_limit: { prussian: 3, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [{ name: '2', distance: 2, price: 80, rusts_on: '4', num: 9 },
                  { name: '2+2', distance: 2, price: 120, rusts_on: '4+4', num: 4 },
                  { name: '3', distance: 3, price: 180, rusts_on: '6', num: 4 },
                  { name: '3+3', distance: 3, price: 270, rusts_on: '6+6', num: 3 },
                  { name: '4', distance: 4, price: 360, num: 3 },
                  { name: '4+4', distance: 4, price: 440, num: 1 },
                  { name: '5', distance: 5, price: 500, num: 2 },
                  { name: '5+5', distance: 5, price: 600, num: 1 },
                  { name: '6', distance: 6, price: 600, num: 2 },
                  { name: '6+6', distance: 6, price: 720, num: 4 }].freeze

        COMPANIES = [
          {
            name: 'Leipzig-Dresdner Bahn',
            sym: 'LD',
            value: 190,
            revenue: 20,
            desc: 'Leipzig-Dresdner Bahn - Sachsen Direktor Papier',
            abilities: [{ type: 'shares', shares: %w[SX_0 SX_1] },
                        { type: 'no_buy' },
                        { type: 'close', when: 'bought_train', corporation: 'SX' }],
            color: nil,
          },
          {
            name: 'Ostbayrische Bahn',
            sym: 'OBB',
            value: 120,
            revenue: 10,
            desc: 'Ostbayrische Bahn - 2 Tiles on M15, M17 extra (one per OR) and without cost',
            abilities: [
              {
                type: 'tile_lay',
                description: "Place a free track tile at m15, M17 at any time during the corporation's operations.",
                owner_type: 'player',
                hexes: %w[M15 M17],
                tiles: %w[3 4 7 8 9 58],
                free: true,
                count: 1,
              },
              { type: 'shares', shares: 'BY_2' },
            ],
            color: nil,
          },
          {
            name: 'Nürnberg-Fürth',
            sym: 'NF',
            value: 100,
            revenue: 5,
            desc: 'Nürnberg-Fürth Bahn, Director of AG may lay token on L14 north or south',
            abilities: [{ type: 'shares', shares: 'BY_2' }],
            color: nil,
          },
          {
            name: 'Hannoversche Bahn',
            sym: 'HB',
            value: 160,
            revenue: 30,
            desc: '10 Percent Share of Preussische Bahn on Exchange',
            abilities: [
              {
                type: 'exchange',
                corporations: ['PR'],
                owner_type: 'player',
                when: ['Phase 2.3', 'Phase 2.4', 'Phase 3.1'],
                from: 'ipo',
              },
            ],
            color: nil,
          },
          {
            name: 'Pfalzbahnen',
            sym: 'PB',
            value: 150,
            revenue: 15,
            desc: 'Can lay a tile on L6 and Token on L6 if Baden AG is active already',
            abilities: [
              {
                type: 'teleport',
                owner_type: 'player',
                free_tile_lay: true,
                hexes: ['L6'],
                tiles: %w[210 211 212 213 214 215],
              },
              { type: 'shares', shares: 'BY_1' },
            ],
            color: nil,
          },
          {
            name: 'Braunschweigische Bahn',
            sym: 'BB',
            value: 130,
            revenue: 25,
            desc: 'Can be exchanged for a 10% share of Preussische Bahn',
            abilities: [
              {
                type: 'exchange',
                corporations: ['PR'],
                owner_type: 'player',
                when: ['Phase 2.3', 'Phase 2.4', 'Phase 3.1'],
                from: 'ipo',
              },
            ],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'BY',
            name: 'Bayrische Eisenbahn',
            logo: '1835/BY',
            simple_logo: '1835/BY.alt',
            tokens: [0, 0, 0, 0, 0],
            coordinates: 'O15',
            color: :Blue,
            reservation_color: nil,
          },
          {
            sym: 'OL',
            name: 'Oldenburgische Eisenbahn',
            logo: '1835/OL',
            simple_logo: '1835/OL.alt',
            tokens: [0, 0],
            coordinates: 'D6',
            color: '#6e6966',
            reservation_color: nil,
          },
          {
            sym: 'SX',
            name: 'Sächsische Eisenbahn',
            logo: '1835/SX',
            simple_logo: '1835/SX.alt',
            tokens: [0, 0, 0],
            coordinates: 'H16',
            color: '#d81e3e',
            reservation_color: nil,
          },
          {
            sym: 'BA',
            name: 'Badische Eisenbahn',
            logo: '1835/BA',
            simple_logo: '1835/BA.alt',
            tokens: [0, 0],
            coordinates: 'L6',
            color: '#7b352a',
            reservation_color: nil,
          },
          {
            sym: 'HE',
            name: 'Hessische Eisenbahn',
            logo: '1835/HE',
            simple_logo: '1835/HE.alt',
            tokens: [0, 0],
            coordinates: 'J8',
            color: :green,
            reservation_color: nil,
          },
          {
            sym: 'WT',
            name: 'Württembergische Eisenbahn',
            logo: '1835/WT',
            simple_logo: '1835/WT.alt',
            tokens: [0, 0],
            coordinates: 'M9',
            color: :yellow,
            reservation_color: nil,
          },
          {
            sym: 'MS',
            name: 'Eisenbahn Mecklenburg Schwerin',
            logo: '1835/MS',
            simple_logo: '1835/MS.alt',
            tokens: [0, 0],
            coordinates: 'C13',
            color: :violet,
            reservation_color: nil,
          },
          {
            sym: 'PR',
            name: 'Preussische Eisenbahn',
            logo: '1835/PR',
            simple_logo: '1835/PR.alt',
            tokens: [0, 0, 0, 0, 0],
            coordinates: 'E19',
            color: '#37383a',
            reservation_color: nil,
          },
        ].freeze

        MINORS = [
          {
            sym: 'P1',
            name: 'Bergisch Märkische Bahn',
            logo: '1835/PR',
            simple_logo: '1835/PR.alt',
            tokens: [0],
            coordinates: 'H2',
            color: '#37383a',
          },
          {
            sym: 'P2',
            name: 'Berlin Potsdamer Bahn',
            logo: '1835/PR',
            simple_logo: '1835/PR.alt',
            tokens: [0],
            coordinates: 'E19',
            color: '#37383a',
          },
          {
            sym: 'P3',
            name: 'Magdeburger-Bahn',
            logo: '1835/PR',
            simple_logo: '1835/PR.alt',
            tokens: [0],
            coordinates: 'F14',
            color: '#37383a',
          },
          {
            sym: 'P4',
            name: 'Köln-Mindener Bahn',
            logo: '1835/PR',
            simple_logo: '1835/PR.alt',
            tokens: [0],
            coordinates: 'G5',
            color: '#37383a',
          },
          {
            sym: 'P5',
            name: 'Berlin Stettiner Bahn',
            logo: '1835/PR',
            simple_logo: '1835/PR.alt',
            tokens: [0],
            coordinates: 'E19',
            color: '#37383a',
          },
          {
            sym: 'P6',
            name: 'Altona Kiel Bahn',
            logo: '1835/PR',
            simple_logo: '1835/PR.alt',
            tokens: [0],
            coordinates: 'C11',
            color: '#37383a',
          },
        ].freeze

        LOCATION_NAMES = {
          'B8' => 'Inverness',
          'B12' => 'Aberdeen',
          'C7' => 'Pitlochry',
          'D10' => 'Montrose',
          'E1' => 'Oban',
          'E7' => 'Perth',
          'E9' => 'Dundee',
          'F2' => 'Helensburgh & Gourock',
          'F4' => 'Dumbarton',
          'F6' => 'Stirling',
          'F8' => 'Dunfermline & Kirkaldy',
          'F10' => 'Anstruther',
          'G3' => 'Greenock',
          'G5' => 'Glasgow',
          'G7' => 'Coatbridge & Airdrie',
          'G9' => 'Edinburgh & Leith',
          'H4' => 'Kilmarnock & Ayr',
          'H6' => 'Motherwell',
          'J2' => 'Stranraer',
          'J6' => 'Dumfries',
          'J10' => 'Carlisle',
          'J14' => 'Newcastle upon Tyne & Sunderland',
          'K7' => 'Maryport',
          'K13' => 'Durham',
          'K15' => 'Stockton on Tees & Middlesbrough',
        }.freeze

        HEXES = {
          white: {
            %w[C11
               G11
               H12
               H14
               I5
               J8] => '',
            %w[C9
               D2
               D4
               D6
               D8
               E3
               E5
               H8
               H10
               I3
               I7
               I9
               I11
               J4
               J12
               K9
               K11] => 'upgrade=cost:100,terrain:mountain',
            ['C7'] => 'town=revenue:0,loc:5.5;upgrade=cost:100,terrain:mountain',
            ['D10'] => 'town=revenue:0,loc:3',
            ['E9'] => 'city=revenue:0,loc:2.5;upgrade=cost:80,terrain:water',
            ['F4'] => 'town=revenue:0,loc:5.5;upgrade=cost:140,terrain:mountain|water',
            ['F6'] => 'town=revenue:0',
            ['F8'] => 'town=revenue:0,loc:1.5;town=revenue:0,loc:3;upgrade=cost:120,terrain:water',
            ['G3'] => 'city=revenue:0,loc:2.5',
            ['G7'] => 'town=revenue:0,loc:1;town=revenue:0,loc:center',
            ['H4'] => 'town=revenue:0,loc:0.5;town=revenue:0,loc:3',
            ['H6'] => 'city=revenue:0,loc:2.5',
            ['I13'] => 'town=revenue:0,loc:center;town=revenue:0,loc:4.5',
            ['J2'] => 'city=revenue:0,loc:1',
            ['J6'] => 'city=revenue:0,loc:3',
            ['J10'] => 'city=revenue:0,loc:1',
            ['K13'] => 'town=revenue:0,loc:3.5',
            ['K15'] => 'town=revenue:0,loc:5;town=revenue:0,loc:0',
          },
          yellow: {
            ['G9'] => 'city=revenue:0,loc:1;city=revenue:0,loc:3',
            ['J14'] => 'city=revenue:0,loc:5;city=revenue:0,loc:2;upgrade=cost:40,terrain:water',
          },
          green: {
            ['G5'] => 'city=revenue:40;path=a:1,b:_0;'\
                      'city=revenue:40;path=a:3,b:_1;'\
                      'city=revenue:40;path=a:5,b:_2',
          },
          gray: {
            ['B8'] => 'city=revenue:20,loc:5.5;path=a:0,b:_0;path=a:5,b:_0',
            ['B12'] => 'city=revenue:30,loc:0;path=a:0,b:_0',
            ['E1'] => 'city=revenue:20,loc:2.5;path=a:3,b:_0;path=a:4,b:_0',
            ['E7'] => 'city=revenue:10,slots:2;'\
                      'path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            ['F2'] => 'town=revenue:10,loc:4;path=a:4,b:_0;'\
                      'town=revenue:10,loc:1;path=a:5,b:_1',
            ['F10'] => 'town=revenue:10,loc:2;path=a:2,b:_0;path=a:5,b:0',
            ['K7'] => 'city=revenue:10,loc:3;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['B6'] => 'offboard=revenue:0;path=a:5,b:_0',
            ['B10'] => 'offboard=revenue:0;path=a:0,b:_0;path=a:5,b:_0',
            ['C1'] => 'offboard=revenue:0;path=a:5,b:_0',
            ['C3'] => 'offboard=revenue:0;path=a:0,b:_0;path=a:5,b:_0',
            ['C5'] => 'offboard=revenue:0;path=a:0,b:_0;path=a:5,b:_0;path=a:4,b:_0',
            ['L8'] => 'offboard=revenue:0;path=a:2,b:_0;path=a:3,b:_0',
            ['L10'] => 'offboard=revenue:0;path=a:2,b:_0;path=a:3,b:_0',
            ['L12'] => 'offboard=revenue:0;path=a:2,b:_0;path=a:3,b:_0',
            ['L14'] => 'offboard=revenue:0;path=a:2,b:_0;path=a:3,b:_0',
            ['L16'] => 'offboard=revenue:0;path=a:2,b:_0',
          }
        }.freeze

        LAYOUT = :pointy

        SELL_MOVEMENT = :down_per_10

        HOME_TOKEN_TIMING = :operating_round

        def setup
          # 1 of each right is reserved w/ the private when it gets bought in. This leaves 2 extra to sell.
          @available_bridge_tokens = 2
          @available_tunnel_tokens = 2
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Step::Bankrupt,
            Step::Exchange,
            Step::BuyCompany,
            Step::SpecialTrack,
            Step::SpecialToken,
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
