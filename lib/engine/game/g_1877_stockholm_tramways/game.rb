# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G1877StockholmTramways
      class Game < Game::Base
        include_meta(G1877StockholmTramways::Meta)

        register_colors(black: '#000000')

        CURRENCY_FORMAT_STR = '%dkr'

        BANK_CASH = 99_999

        CERT_LIMIT = {
          3 => 16,
          4 => 12,
          5 => 10,
          6 => 9,
        }.freeze

        STARTING_CASH = {
          3 => 600,
          4 => 450,
          5 => 360,
          6 => 300,
        }.freeze

        TILES = {
          '4' => 2,
          '6' => 4,
          '8' => 4,
          '9' => 4,
          '19' => 1,
          '23' => 1,
          '24' => 1,
          '25' => 1,
          '58' => 3,
          '141' => 1,
          '142' => 1,
          '144' => 1,
          '147' => 2,
          '441' => 2,
          '442' => 2,
          '448' => 2,
          '546' => 1,
          'X1' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:0,b:_0;path=a:_0,b:3;label=C',
          },
          'X2' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=C',
          },
          'X3' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:_0,b:3;path=a:1,b:_1;path=a:_1,b:5;label=L',
          },
          'X4' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2,loc:0;city=revenue:50;'\
                      'path=a:1,b:_0;path=a:_0,b:5;path=a:2,b:_1;path=a:_1,b:3;label=N',
          },
          'X5' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=S',
          },
          'X6' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=C',
          },
          'X7' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=L',
          },
          'X8' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:80,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=N',
          },
          'X9' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:2,loc:0;city=revenue:70;'\
                      'path=a:1,b:_0;path=a:_0,b:5;path=a:2,b:_1;path=a:_1,b:3;path=a:_1,b:4;label=N',
          },
          'X10' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=S',
          },
        }.freeze

        LOCATION_NAMES = {
          'A9' => 'Norrtälje',
          'B8' => 'Rimbo',
          'C7' => 'Djursholm',
          'C11' => 'Kyrkviken',
          'D2' => 'Sundbyberg',
          'D4' => 'Råsunda',
          'D10' => 'Lidingö',
          'E1' => 'Ulvsunda',
          'E7' => 'Östermalm',
          'E11' => 'Skärsätra',
          'F2' => 'Alvik',
          'F4' => 'Kungsholmen',
          'F6' => 'Norrmalm',
          'F8' => 'Djurgården',
          'G1' => 'Ålsten',
          'G5' => 'Liljeholmen',
          'G7' => 'Södermalm',
          'G9' => 'Sickla',
          'G11' => 'Saltsjö-Duvnäs',
          'H4' => 'Mälarhöjden',
          'H8' => 'Enskede',
          'I5' => 'Örby',
          'I7' => 'Brännkyrka',
          'I9' => 'Gubbängen',
          'I13' => 'Saltsjöbaden',
        }.freeze

        CAPITALIZATION = :full

        MARKET = [
          %w[35 40 45
             50p 60p 70p 80p 90p 100p
             120 140 160 180 200
             240 280 320 360 400e],
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
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 80,
            rusts_on: '4',
            num: 6,
          },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6',
            num: 5,
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: 'D',
            num: 4,
          },
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
          },
        ].freeze

        COMPANIES = [].freeze

        CORPORATIONS = [
          {
            float_percent: 50,
            sym: 'SS',
            name: 'AB Stockholms Spårvägar',
            logo: '1877_stockholm_tramways/SS',
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            tokens: [0, 60, 60, 60, 60, 60],
            coordinates: 'F6',
            city: 0,
            color: '#9A9A9D',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'SF',
            name: 'AB Södra Förstadsbanan',
            logo: '1877_stockholm_tramways/SF',
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            tokens: [0, 60, 60, 60, 60, 60],
            coordinates: 'H4',
            color: '#7BB137',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'D',
            name: 'Djursholms AB',
            logo: '1877_stockholm_tramways/D',
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            tokens: [0, 60, 60, 60, 60, 60],
            coordinates: 'C7',
            color: '#06038D',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'JSS',
            name: 'Järnvägs AB Stockholm-Saltsjön',
            logo: '1877_stockholm_tramways/JSS',
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            tokens: [0, 60, 60, 60, 60, 60],
            coordinates: 'I13',
            color: '#881A1E',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'LT',
            name: 'Lidingö Trafik AB',
            logo: '1877_stockholm_tramways/LT',
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            tokens: [0, 60, 60, 60, 60, 60],
            coordinates: 'D10',
            city: 0,
            color: '#235758',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'RF',
            name: 'Råsunda Förstads AB',
            logo: '1877_stockholm_tramways/RF',
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            tokens: [0, 60, 60, 60, 60, 60],
            coordinates: 'D4',
            color: '#008F4F',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'SRJ',
            name: 'Stockholm-Rimbo Järnvägs AB',
            logo: '1877_stockholm_tramways/SRJ',
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            tokens: [0, 60, 60, 60, 60, 60],
            coordinates: 'A9',
            color: '#FCEA18',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'SNS',
            name: 'Stockholms Nya Spårvägs AB',
            logo: '1877_stockholm_tramways/SNS',
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            tokens: [0, 60, 60, 60, 60, 60],
            coordinates: 'F6',
            city: 1,
            color: '#EC767C',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'SSS',
            name: 'Stockholms Stads Spårväg',
            logo: '1877_stockholm_tramways/SSS',
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            tokens: [0, 60, 60, 60, 60, 60],
            coordinates: 'G1',
            color: '#4D2674',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'SSB',
            name: 'Stockholms Södra Spårvägs AB',
            logo: '1877_stockholm_tramways/SSB',
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            tokens: [0, 60, 60, 60, 60, 60],
            coordinates: 'G7',
            color: '#DD0030',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'SST',
            name: 'Södra Spårvägarnes Trafik AB',
            logo: '1877_stockholm_tramways/SST',
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            tokens: [0, 60, 60, 60, 60, 60],
            coordinates: 'H8',
            color: '#0A70B3',
            reservation_color: nil,
          },
          {
            float_percent: 50,
            sym: 'TSSL',
            name: 'Trafik AB Stockholm-Södra Lidingön',
            logo: '1877_stockholm_tramways/TSSL',
            shares: [20, 10, 10, 10, 10, 10, 10, 10, 10],
            tokens: [0, 60, 60, 60, 60, 60],
            coordinates: 'D10',
            city: 1,
            color: '#EB6f0E',
            reservation_color: nil,
          },
        ].freeze

        HOME_TOKEN_TIMING = :float
        SELL_AFTER = :after_ipo
        SELL_BUY_ORDER = :sell_buy
        MARKET_SHARE_LIMIT = 100
        CERT_LIMIT_INCLUDES_PRIVATES = false

        GAME_END_CHECK = { stock_market: :current_round, custom: :current_or }.freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
           'sl_trigger' => ['SL Trigger', 'SL will form at end of OR, game ends at end of following OR set'],
         ).freeze

        HEXES = {
          white: {
            %w[E5 H6] => 'blank',
            %w[B10 C9 D6 D8 D12 E3 E9 F10 G3 H10 H12 I11] => 'upgrade=cost:40,terrain:water',
            %w[B8 C11 I5 I9] => 'town',
            %w[F2 G5 G9] => 'town=revenue:0;upgrade=cost:40,terrain:water',
            %w[D2 C7 E11 G11 H8 I7] => 'city=revenue:0',
            ['F8'] => 'city=revenue:0;upgrade=cost:40,terrain:water',
            ['E7'] => 'city=revenue:0;label=C',
            ['F4'] => 'city=revenue:0,loc:5.5;label=C;upgrade=cost:40,terrain:water',
          },
          yellow: {
            ['D4'] => 'city=revenue:20;path=a:1,b:_0;path=a:_0,b:5',
            ['D10'] =>
            'city=revenue:20;city=revenue:20;path=a:1,b:_0;path=a:_0,b:3;path=a:1,b:_1;path=a:_1,b:5;label=L',
            ['F6'] => 'city=revenue:30,loc:0;city=revenue:30;'\
                      'path=a:1,b:_0;path=a:2,b:_1;path=a:_1,b:3;label=N;upgrade=cost:40,terrain:water',
            ['G7'] => 'city=revenue:10;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=S;upgrade=cost:40,terrain:water',
            ['H4'] => 'city=revenue:20;path=a:3,b:_0;path=a:_0,b:5',
          },
          gray: {
            ['A9'] => 'city=revenue:yellow_40|brown_30;path=a:0,b:_0;path=a:_0,b:5',
            ['C3'] => 'path=a:0,b:5',
            ['E1'] => 'town=revenue:30;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['G1'] => 'city=revenue:yellow_10|brown_30;path=a:3,b:_0;path=a:4,b:_0',
            ['I13'] => 'city=revenue:yellow_60|brown_40;path=a:1,b:_0;path=a:2,b:_0',
          },
        }.freeze

        LAYOUT = :pointy

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::BuyTrain,
          ], round_num: round_num)
        end

        def init_stock_market
          StockMarket.new(self.class::MARKET, [])
        end

        def init_round
          stock_round
        end
      end
    end
  end
end
