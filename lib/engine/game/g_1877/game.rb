# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../g_1817/game'
require_relative '../g_1817/round/stock'

module Engine
  module Game
    module G1877
      class Game < G1817::Game
        include_meta(G1877::Meta)
        include Entities
        include Map

        CURRENCY_FORMAT_STR = 'Bs.%s'

        BANK_CASH = 99_999

        CERT_LIMIT = { 2 => 21, 3 => 16, 4 => 13, 5 => 11, 6 => 9, 7 => 9 }.freeze

        STARTING_CASH = { 2 => 420, 3 => 315, 4 => 252, 5 => 210, 6 => 180, 7 => 142 }.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false

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
