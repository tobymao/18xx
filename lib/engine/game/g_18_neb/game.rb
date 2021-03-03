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

        MUST_SELL_IN_BLOCKS = true

        TILES = {
          # yellow
          '3' => 4,
          '4' => 6,
          '58' => 6,
          '7' => 4,
          '8' => 14,
          '9' => 14,
          # green
          '80' => 1,
          '81' => 1,
          '82' => 1,
          '83' => 1,
          #'226' => 2,
          #'227' => 2,
          #'228' => 2,
          #'229' => 1,
          #'407' => 1,
          ## brown
          #'544' => 2,
          #'545' => 2,
          #'546' => 2,
          #'611' => 6,
          #'230' => 1,
          #'234' => 1,
          #'233' => 1,
          ## gray
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
          %w[75 82 90 100 110 122 135 150 165 180 200 220 270 300 330 360],
          %w[70 75 82 90 100 110 122 135 150 165 180 200 220],
          %w[65 70 75 82 90 100 110 122 135 150 165],
          %w[60 65 70 75 82 90 100 110],
          %w[50 60 65 70 75 82],
          %w[40 50 60 65 70],
          %w[30 40 50 60],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
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
            distance: 2,
            price: 100,
            rusts_on: '4+4',
            num: 5,
          },
          {
            name: '3+3',
            distance: 3,
            price: 200,
            rusts_on: '6/8',
            num: 4,
          },
          {
            name: '4+4',
            distance: 4,
            price: 300,
            rusts_on: '4D',
            num: 3,
          },
          {
            name: '5/7',
            distance: 5,
            price: 450,
            num: 2,
            events: [{ 'type' => 'close_companies' }],
          },
          { name: '6/8', distance: 6, price: 600, num: 2 },
          {
            name: '4D',
            distance: 999,
            price: 900,
            num: 20,
            available_on: '6',
            discount: { '4' => 300, '5' => 300, '6' => 300 },
          },
].freeze

        COMPANIES = [
          {
            name: 'Takamatsu E-Railroad',
            value: 20,
            revenue: 5,
            desc: 'Blocks Takamatsu (K4) while owned by a player.',
            sym: 'TR',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['K4'] }],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'UP',
            name: 'Union Pacific',
            logo: '1889/AR',
            tokens: [0, 40, 100],
            coordinates: 'K8',
            color: '#37383a',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'IR',
            name: 'Iyo Railway',
            logo: '1889/IR',
            tokens: [0, 40],
            coordinates: 'E2',
            color: '#f48221',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'SR',
            name: 'Sanuki Railway',
            logo: '1889/SR',
            tokens: [0, 40],
            coordinates: 'I2',
            color: '#76a042',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'KO',
            name: 'Takamatsu & Kotohira Electric Railway',
            logo: '1889/KO',
            tokens: [0, 40],
            coordinates: 'K4',
            color: '#d81e3e',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'TR',
            name: 'Tosa Electric Railway',
            logo: '1889/TR',
            tokens: [0, 40, 40],
            coordinates: 'F9',
            color: '#00a993',
            reservation_color: nil,
          },
        ].freeze

        HEXES = {
          green: {
            %w[D3 H3 J3 B5 C8 E8 I8 D9 I10] => '',
            %w[F3 G4 H7 A10 J11 G12 E2 I2 K8 C10] => 'city=revenue:0',
            ['J5'] => 'town=revenue:0',
            %w[B11 G10 I12 J9] => 'town=revenue:0;icon=image:port',
            ['K6'] => 'upgrade=cost:80,terrain:water',
            %w[H5 I6] => 'upgrade=cost:80,terrain:water|mountain',
            %w[E4 D5 F5 C6 E6 G6 D7 F7 A8 G8 B9 H9 H11 H13] => 'upgrade=cost:80,terrain:mountain',
            ['I4'] => 'city=revenue:0;label=H;upgrade=cost:80',
          },
          yellow: {
            ['C4'] => 'city=revenue:20;path=a:2,b:_0',
            ['K4'] => 'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;label=T',
          },
          gray: {
            ['B7'] => 'city=revenue:40,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            ['B3'] => 'town=revenue:20;path=a:0,b:_0;path=a:_0,b:5',
            ['G14'] => 'town=revenue:20;path=a:3,b:_0;path=a:_0,b:4',
            ['J7'] => 'path=a:1,b:5',
          },
          red: {
            ['F1'] => 'offboard=revenue:yellow_30|brown_60|diesel_100;path=a:0,b:_0;path=a:1,b:_0',
            ['J1'] => 'offboard=revenue:yellow_20|brown_40|diesel_80;path=a:0,b:_0;path=a:1,b:_0',
            ['L7'] => 'offboard=revenue:yellow_20|brown_40|diesel_80;path=a:1,b:_0;path=a:2,b:_0',
          },
          white: {
            ['F9'] => 'city=revenue:30,slots:2;path=a:2,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;path=a:5,b:_0;label=K;upgrade=cost:80,terrain:water',
          },
        }.freeze

        LAYOUT = :flat

        EBUY_PRES_SWAP = false # allow presidential swaps of other corps when ebuying
        EBUY_OTHER_VALUE = false # allow ebuying other corp trains for up to face
        HOME_TOKEN_TIMING = :operating_round

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

        def active_players
          return super if @finished

          company = company_by_id('ER')
          current_entity == company ? [@round.company_sellers[company]] : super
        end
      end
    end
  end
end
