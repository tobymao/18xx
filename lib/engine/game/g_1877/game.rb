# frozen_string_literal: true

require_relative 'meta'
require_relative '../g_1817/game'
require_relative '../g_1817/round/stock'

module Engine
  module Game
    module G1877
      class Game < G1817::Game
        include_meta(G1877::Meta)

        CURRENCY_FORMAT_STR = 'Bs.%d'

        BANK_CASH = 99_999

        CERT_LIMIT = { 2 => 21, 3 => 16, 4 => 13, 5 => 11, 6 => 9, 7 => 9 }.freeze

        STARTING_CASH = { 2 => 420, 3 => 315, 4 => 252, 5 => 210, 6 => 180, 7 => 142 }.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false

        TILES = {
          '5' => 'unlimited',
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '441' => 'unlimited',
          '442' => 'unlimited',
          '444' => 'unlimited',
          '80' => 'unlimited',
          '81' => 'unlimited',
          '82' => 'unlimited',
          '83' => 'unlimited',
          '38' => 'unlimited',
          'X1' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' =>
            'city=revenue:50;city=revenue:50;path=a:1,b:_0;path=a:_1,b:5;label=C',
          },
          'X2' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'city=revenue:50;path=a:0,b:_0;label=M',
          },
          'X3' =>
          {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;path=a:1,b:_0;path=a:_0,b:5;label=C',
          },
          'X4' =>
          {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'city=revenue:60;path=a:0,b:_0;label=M',
          },
          'X5' =>
          {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:0,b:_0;path=a:3,b:_0;label=⛏️',
          },
          'X6' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'city=revenue:20;path=a:0,b:_0;path=a:3,b:_0;label=⛏️',
          },
          'X7' =>
          {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'city=revenue:10;path=a:0,b:_0;path=a:3,b:_0;label=⛏️',
          },
        }.freeze

        LOCATION_NAMES = {
          'E2' => 'Acarigua',
          'H3' => 'Barcelona',
          'D3' => 'Barquisimeto',
          'G6' => 'Cabruta',
          'F5' => 'Calabozo',
          'F1' => 'Caracas',
          'A6' => 'Colombia',
          'B5' => 'San Cristobal',
          'H5' => 'El Pilar',
          'I4' => 'Guayana City',
          'L5' => 'Guyana',
          'B1' => 'Maracaibo',
          'C4' => 'El Vigía',
          'F3' => 'San Juan de Los Morros',
          'J1' => 'Trinidad & Tobago',
          'G4' => 'Zaraza',
        }.freeze

        MARKET = [
          %w[0l
             0a
             0a
             0a
             40
             45
             50p
             55p
             60p
             65p
             70p
             80p
             90p
             100p
             110p
             120p
             135p
             150p
             165p
             180p
             200p
             220
             245
             270
             300
             330
             360
             400
             440
             490
             540
             600],
           ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
            corporation_sizes: [5],
          },
          {
            name: '2+',
            on: '2+',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
            corporation_sizes: [5],
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            corporation_sizes: [5],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            corporation_sizes: [5],
          },
        ].freeze

        TRAINS = [{ name: '2', distance: 2, price: 100, rusts_on: '4', num: 40 },
                  { name: '2+', distance: 2, price: 100, obsolete_on: '4', num: 3 },
                  { name: '3', distance: 3, price: 250, num: 10 },
                  {
                    name: '4',
                    distance: 4,
                    price: 300,
                    num: 40,
                    events: [{ 'type' => 'signal_end_game' }],
                  }].freeze

        CORPORATIONS = [
          {
            float_percent: 20,
            sym: 'BPC',
            name: 'Ferroviario de Barquisimento y Puerto Caballo',
            logo: '1877/BPC',
            shares: [40, 20, 20, 20],
            max_ownership_percent: 60,
            tokens: [0],
            always_market_price: true,
            color: :dodgerblue,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'BSC',
            name: 'Ferroviario de Barinas y San Cristobál',
            logo: '1877/BSC',
            shares: [40, 20, 20, 20],
            max_ownership_percent: 60,
            tokens: [0],
            always_market_price: true,
            text_color: 'black',
            color: :lightgreen,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'Cap',
            name: 'Capital Line',
            logo: '1877/CAP',
            shares: [40, 20, 20, 20],
            max_ownership_percent: 60,
            tokens: [0],
            always_market_price: true,
            text_color: 'black',
            color: :'#FFD700',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'CLG',
            name: 'Ferroviario de Caracas y La Guaira',
            logo: '1877/CLG',
            shares: [40, 20, 20, 20],
            max_ownership_percent: 60,
            tokens: [0],
            always_market_price: true,
            color: :deeppink,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'E&M',
            name: 'Ferroviario de Encontrados y Machiques',
            logo: '1877/EM',
            shares: [40, 20, 20, 20],
            max_ownership_percent: 60,
            tokens: [0],
            always_market_price: true,
            color: :darkmagenta,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'FCC',
            name: 'Ferroviario de Caracas y Cúa',
            logo: '1877/FCC',
            shares: [40, 20, 20, 20],
            max_ownership_percent: 60,
            tokens: [0],
            always_market_price: true,
            color: '#ef4223',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'LESJ',
            name: 'Ferroviario de La Encrucijada y San Juan de Los Morros',
            logo: '1877/LESJ',
            shares: [40, 20, 20, 20],
            max_ownership_percent: 60,
            tokens: [0],
            always_market_price: true,
            text_color: 'black',
            color: '#f2a847',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'M&M',
            name: 'Ferroviario de Machiques y Maracaibo',
            logo: '1877/MM',
            shares: [40, 20, 20, 20],
            max_ownership_percent: 60,
            tokens: [0],
            always_market_price: true,
            color: :saddlebrown,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'PCB',
            name: 'Ferroviario de Puerto Cabello y Barquisimeto',
            logo: '1877/PCB',
            shares: [40, 20, 20, 20],
            max_ownership_percent: 60,
            tokens: [0],
            always_market_price: true,
            color: :darkgreen,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'Sans',
            name: 'Ferroviario de San Juan de Los Morros y San Fernando de Apure',
            logo: '1877/SANS',
            shares: [40, 20, 20, 20],
            max_ownership_percent: 60,
            tokens: [0],
            always_market_price: true,
            text_color: 'black',
            color: :aqua,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'SMB',
            name: 'Ferroviario de Sabana de Mendoza y Barquisimeto',
            logo: '1877/SMB',
            shares: [40, 20, 20, 20],
            max_ownership_percent: 60,
            tokens: [0],
            always_market_price: true,
            color: :silver,
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'TCM',
            name: 'Tucucas Copper Mining Railway',
            logo: '1877/TCM',
            shares: [40, 20, 20, 20],
            max_ownership_percent: 60,
            tokens: [0],
            always_market_price: true,
            color: '#16190e',
            reservation_color: nil,
          },
        ].freeze

        HEXES = {
          white: {
            %w[C6 D5 E4 E6 G2 G8 H7 I6 J5 D1] => '',
            ['C2'] => 'border=edge:2,type:impassable;border=edge:1,type:impassable',
            ['B3'] => 'border=edge:4,type:impassable',
            ['K4'] => 'border=edge:2,type:impassable',
            ['J3'] => 'border=edge:5,type:impassable',
            ['I2'] => 'upgrade=cost:15,terrain:mountain',
            %w[D3 C4] => 'city=revenue:0;upgrade=cost:15,terrain:mountain',
            %w[E2 H3 F5 B5 F3 G4] => 'city=revenue:0',
            ['F7'] => 'upgrade=cost:10,terrain:water',
            %w[G6 I4 H5] => 'city=revenue:0;upgrade=cost:10,terrain:water',
          },
          red: {
            ['A6'] => 'offboard=revenue:yellow_20|green_30;path=a:4,b:_0',
            ['L5'] => 'offboard=revenue:yellow_20|green_30|brown_40;path=a:2,b:_0',
            ['J1'] => 'offboard=revenue:yellow_20|green_30|brown_40;path=a:1,b:_0',
          },
          yellow: {
            ['F1'] =>
                     'city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:_1,b:5;label=C',
            ['B1'] =>
            'city=revenue:40;path=a:0,b:_0;label=M;border=edge:5,type:impassable',
          },
        }.freeze

        LAYOUT = :flat

        DISCARDED_TRAINS = :remove

        SELL_AFTER = :any_time

        EVENTS_TEXT = Base::EVENTS_TEXT.merge('signal_end_game' => ['Signal End Game',
                                                                    'Game ends 3 ORs after purchase/export'\
                                                                    ' of first 4 train']).freeze
        MINE_HEXES = %w[B5 C4 D3 E2 F3 F5 G4 G6 H3 H5 I4].freeze

        def no_mines?
          @optional_rules.include?(:no_mines)
        end

        def setup
          if no_mines?
            @tiles.reject! { |t| %w[X5 X6 X7].include?(t.name) }
            @all_tiles.reject! { |t| %w[X5 X6 X7].include?(t.name) }
          else
            MINE_HEXES.sort_by { rand }.take(2).each do |hex_id|
              hex_by_id(hex_id).tile.label = '⛏️'
            end
          end
          super
        end

        def event_signal_end_game!
          @final_operating_rounds = 2
          game_end_check
          @final_turn -= 1 if @round.stock?
          @log << "First 4 train bought/exported, ending game at the end of #{@final_turn}.#{@final_operating_rounds}"
        end

        def size_corporation(corporation, size)
          corporation.second_share = nil

          if size == 10
            original_shares = @_shares.values.select { |share| share.corporation == corporation }

            corporation.share_holders.clear
            shares = Array.new(5) { |i| Share.new(corporation, percent: 10, index: i + 1) }

            original_shares.each do |share|
              share.percent = share.president ? 20 : 10
              corporation.share_holders[share.owner] += share.percent
            end

            shares.each do |share|
              add_new_share(share)
            end
          end

          @log << "#{corporation.name} floats and transfers 60% to the market"
          corporation.spend(corporation.cash, @bank)
          @bank.spend(((corporation.par_price.price * corporation.total_shares) / 2).floor, corporation)

          total = 0
          shares = corporation.shares.take_while { |share| (total += share.percent) <= 60 }
          @share_pool.transfer_shares(ShareBundle.new(shares), @share_pool)
        end

        def float_corporation(corporation); end

        def buy_train(operator, train, price = nil)
          super
          train.buyable = false unless @optional_rules&.include?(:cross_train)
        end

        private

        def init_round
          stock_round
        end

        def stock_round
          close_bank_shorts
          @interest_fixed = nil

          G1817::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::HomeToken,
            G1877::Step::BuySellParShares,
          ])
        end
      end
    end
  end
end
