# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G18NEB
      class Game < Game::Base
        include_meta(G18NEB::Meta)

        register_colors(black: '#37383a',
                        orange: '#f48221',
                        brightGreen: '#76a042',
                        red: '#d81e3e',
                        turquoise: '#00a993',
                        blue: '#0189d1',
                        brown: '#7b352a')

        CURRENCY_FORMAT_STR = '$%d'

        BANK_CASH = 6000

        CERT_LIMIT = { 2 => 21, 3 => 15, 4 => 13 }.freeze

        STARTING_CASH = { 2 => 650, 3 => 450, 4 => 350 }.freeze

        CAPITALIZATION = :incremental
        # However 10-share corps that start in round 5: if their 5th share purchase
        #  - get 5x starting value
        #  - the remaining 5 shares are placed in bank pool

        MUST_SELL_IN_BLOCKS = true

        SELL_BUY_ORDER = :sell_buy
        # is this first to pass: first, second: second.. yes
        NEXT_SR_PLAYER_ORDER = :first_to_pass
        MIN_BID_INCREMENT = 10

        TILES = {
          # Yellow
          '3' => 4,
          '4' => 6,
          '58' => 6,
          '7' => 4,
          '8' => 14,
          '9' => 14,

          # Green
          '80' => 1,
          '81' => 1,
          '82' => 1,
          '83' => 1,
          #'226' => 2,
          #'227' => 2,
          #'228' => 2,
          #'229' => 1,
          #'407' => 1,

          # Brown
          #'544' => 2,
          #'545' => 2,
          #'546' => 2,
          #'611' => 6,
          #'230' => 1,
          #'234' => 1,
          #'233' => 1,

          # Gray
          #'51'  => 2,
          #'231'  => 1,
          #'116'  => 1,
          #'192'  => 1,
          #'409'  => 1,
        }.freeze

        LOCATION_NAMES = {
          'A5' => 'Powder River Basin',
          'A7' => 'West',
          'B2' => 'Pacific Northwest',
          'B6' => 'Scottsbluff',
          'C3' => 'Chadron',
          'C7' => 'Sidney',
          'C9' => 'Denver',
          'E7' => 'Sutherland',
          'F6' => 'North Platte',
          'G1' => 'Valentine',
          'G7' => 'Kearney',
          'G11' => 'McCook',
          'H8' => 'Grand Island',
          'H10' => 'Holdrege',
          'I3' => 'ONeill',
          'I5' => 'Norfolk',
          'J8' => 'Lincoln',
          'J12' => 'Beatrice',
          'K3' => 'South Sioux City',
          'K7' => 'Omaha',
          'L4' => 'Chicago Norh',
          'L6' => 'South Chicago',
          'L10' => 'Nebraska City',
          'L12' => 'Kansas City',
        }.freeze

        MARKET = [
          %w[82 90 100 110 122 135 150 165 180 200 220 270 300 330 360 400],
          %w[75 82 90 100p 110 122 135 150 165 180 200 220 270 300 330 360],
          %w[70 75 82 90p 100 110 122 135 150 165 180 200 220],
          %w[65 70 75 82p 90 100 110 122 135 150 165],
          %w[60 65 70 75p 82 90 100 110],
          %w[50 60 65 70p 75 82],
          %w[40 50 60 65 70],
          %w[30 40 50 60],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
            status: ['can_buy_morison'],
          },
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
            train_limit: 3,
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
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          {
            name: '2+2',
            distance: [{ 'nodes' => %w[town], 'pay' => 2 },
                       { 'nodes' => %w[town city offboard], 'pay' => 2 }],
            price: 100,
            rusts_on: '4+4',
            num: 5,
          },
          {
            name: '3+3',
            distance: [{ 'nodes' => %w[town], 'pay' => 3 },
                       { 'nodes' => %w[town city offboard], 'pay' => 3 }],
            price: 200,
            rusts_on: '6/8',
            num: 4,
          },
          {
            name: '4+4',
            distance: [{ 'nodes' => %w[town], 'pay' => 4 },
                       { 'nodes' => %w[town city offboard], 'pay' => 4 }],
            price: 300,
            rusts_on: '4D',
            num: 3,
          },
          {
            name: '5/7',
            distance: [{ 'pay' => 5, 'visit' => 7 }],
            price: 450,
            num: 2,
            events: [{ 'type' => 'close_companies' }],
          },
          { 
            name: '6/8',
            distance: [{ 'pay' => 6, 'visit' => 8 }],
            price: 600,
            num: 2
          },
          {
            name: '4D',
            distance: 999,
            price: 900,
            num: 20,
            available_on: '6', discount: { '4' => 300, '5' => 300, '6' => 300 },
          },
        ].freeze

        COMPANIES = [
          {
            name: 'Denver Pacific Railroad',
            value: 20,
            revenue: 5,
            desc: 'Once per game, allows Corporation owner to lay or upgrade a tile in B8',
            sym: 'DPR',
            abilities: [
                { type: 'tile_lay', owner_type: 'corporation', hexes: ['B8'], blocks: true, count: 1, on_phase: 3 },
              ],
            color: nil,
          },
          {
            name: 'Morison Bridging Company',
            value: 40,
            revenue: 10,
            desc: 'Corporation owner gets two bridge discount tokens',
            sym: 'MBC',
            abilities: [{ type: 'discount', owner_type: 'corporation', hexes: ['B8'] }],
            color: nil,
          },
          {
            name: 'Armour and Company',
            value: 70,
            revenue: 15,
            desc: 'An owning Corporation may place a cattle token in any Town or City',
            sym: 'AC',
            abilities: [
              { type: 'hex_bonus', owner_type: 'corporation', amount: 10 },
              { type: 'hex_bonus', owner_type: 'corporation', amount: 20 },
            ],
            color: nil,
          },
          {
            name: 'Central Pacific Railroad',
            value: 100,
            revenue: 15,
            desc: 'May exchange for share in Colorado & Southern Railroad',
            sym: 'P4',
            abilities: [{ type: 'shares', shares: 'C&S_1' }],
            color: nil,
          },
          {
            name: 'Crédit Mobilier',
            value: 130,
            revenue: 5,
            desc: '$5 revenue each time ANY tile is laid or upgraded.',
            sym: 'P5',
            # abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['C7'] }],
            color: nil,
          },
          {
            name: 'Union Pacific Railroad',
            value: 175,
            revenue: 25,
            desc: 'Comes with President\'s Certificate of the Union Pacific Railroad',
            sym: 'P6',
            abilities: [{ type: 'shares', shares: 'UP_0' }],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 20,
            sym: 'UP',
            name: 'Union Pacific',
            logo: '1889/AR',
            tokens: [0, 40, 100],
            coordinates: 'K7',
            color: '#37383a',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'CBQ',
            name: 'Chicago Burlington & Quincy',
            logo: '1889/IR',
            tokens: [0, 40],
            coordinates: 'L6',
            color: '#f48221',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'CNW',
            name: 'Chicago & Northwestern',
            logo: '1889/SR',
            tokens: [0, 40],
            coordinates: 'L4',
            color: '#76a042',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'DRG',
            name: 'Denver & Rio Grande',
            logo: '1889/KO',
            tokens: [0, 40],
            coordinates: 'C9',
            color: '#d81e3e',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'MP',
            name: 'Missouri Pacific',
            logo: '1889/TR',
            tokens: [0, 40, 100],
            coordinates: 'L12',
            color: '#00a993',
            reservation_color: nil,
            always_market_price: true,
          },
          {
            float_percent: 20,
            sym: 'C&S',
            name: 'Colorado & Southern',
            logo: '1889/TR',
            tokens: [0, 40, 100],
            coordinates: 'A7',
            color: '#00a993',
            always_market_price: true,
            reservation_color: nil,
          },
        ].freeze

        HEXES = {
          white: {
            # empty tiles
            %w[B4 B8 C5 D2 D4 D6 E3 E5 F2 F4 F8 F10 F12 G3 G5 G9 H2 H4 H6 H12 I7 I9 I11 J2 J4 J6 J10 K9 K11] => '',
            %w[K5 L8] => 'upgrade=cost:60,terrain:water',
            # town tiles
            %w[B6 C3 C7 E7 F6 G7 G11 H8 H10 I3 I5 J12] => 'town=revenue:0',
            %w[K3] => 'town=revenue:0;upgrade=cost:20,terrain:water',
            %w[J8] => 'town=revenue:0;upgrade=cost:40,terrain:water',
            %w[L10] => 'town=revenue:0;upgrade=cost:60,terrain:water',
          },
          yellow: {
            # city tiles
            ['C9'] => 'city=revenue:30;path=a:5,b:_0',
            # Omaha
            ['K7'] => 'city=revenue:30,loc:3;town=revenue:0,loc:4;path=a:1,b:4;path=a:1,b:_0;upgrade=cost:60,terrain:water',
          },
          gray: {
            ['D8'] => 'path=a:5,b:2',
            ['D10'] => 'path=a:4,b:2',
            ['E9'] => 'junction;path=a:5,b:_0;path=a:_0,b:2;path=a:_0,b:1;path=a:_0,b:3',
            ['I1'] => 'path=a:1,b:5',
            ['K1'] => 'path=a:1,b:6',
            ['K13'] => 'path=a:2,b:3',
            ['M9'] => 'path=a:2,b:1',
          },
          red: {
            # Powder River Basin
            ['A5'] => 'offboard=revenue:yellow_0|green_30|brown_60;path=a:4,b:_0;path=a:5,b:_0;path=a:0,b:_0;label=W',
            # West
            ['A7'] => 'city=revenue:yellow_30|green_40|brown_50;path=a:4,b:_0;path=a:5,b:_0;path=a:_0,b:3;label=W',
            # Pacific NW
            ['B2'] => 'offboard=revenue:yellow_30|green_40|brown_50;path=a:0,b:_0;path=a:5,b:_0;label=W',
            # Valentine
            ['G1'] => 'town=revenue:yellow_30|green_40|brown_50;path=a:0,b:_0;path=a:5,b:_0;path=a:1,b:_0',
            # Chi North
            ['L4'] => 'city=revenue:yellow_30|green_50|brown_60;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1;label=E',
            # South Chi
            ['L6'] => 'city=revenue:yellow_20|green_40|brown_60;path=a:2,b:_0,terminal:1;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;label=E',
            # KC
            ['L12'] => 'city=revenue:yellow_30|green_50|brown_60;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1;label=E',
          },
        }.freeze

        LAYOUT = :flat

        EBUY_PRES_SWAP = false # allow presidential swaps of other corps when ebuying
        EBUY_OTHER_VALUE = false # allow ebuying other corp trains for up to face
        HOME_TOKEN_TIMING = :operating_round

        # def init_round
        #   Round::Draft.new(self,
        #                    [G18LosAngeles::Step::DraftDistribution],
        #                    snake_order: true)
        # end

        # borrowed from 1846 for initial reverse corporation order
        def operating_order
          corporations = @corporations.select(&:floated?)
          if @turn == 1 && (@round_num || 1) == 1
            corporations.sort_by! do |c|
              sp = c.share_price
              [sp.price, sp.corporations.find_index(c)]
            end
          else
            corporations.sort!
          end
          @minors.select(&:floated?) + corporations
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::BuyCompany,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, blocks: true],
          ], round_num: round_num)
        end

      end
    end
  end
end
