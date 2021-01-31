# frozen_string_literal: true

require_relative '../config/game/g_1877'
require_relative 'g_1817'

module Engine
  module Game
    class G1877 < G1817
      register_colors(black: '#16190e',
                      blue: '#165633',
                      brightGreen: '#0a884b',
                      brown: '#984573',
                      gold: '#904098',
                      gray: '#984d2d',
                      green: '#bedb86',
                      lavender: '#e96f2c',
                      lightBlue: '#bedef3',
                      lightBrown: '#bec8cc',
                      lime: '#00afad',
                      navy: '#003d84',
                      natural: '#e31f21',
                      orange: '#f2a847',
                      pink: '#ee3e80',
                      red: '#ef4223',
                      turquoise: '#0095da',
                      violet: '#e48329',
                      white: '#fff36b',
                      yellow: '#ffdea8')

      load_from_json(Config::Game::G1877::JSON)

      GAME_DESIGNER = 'Scott Petersen & Toby Mao'
      GAME_RULES_URL = 'https://github.com/tobymao/18xx/wiki/1877'
      GAME_PUBLISHER = :all_aboard_games
      GAME_LOCATION = 'Venezuela'

      OPTIONAL_RULES = [].freeze

      DEV_STAGE = :alpha

      SELL_AFTER = :any_time

      def size_corporation(corporation, size)
        if size == 10
          original_shares = @_shares.values.select { |share| share.corporation == corporation }

          corporation.share_holders.clear
          shares = 5.times.map { |i| Share.new(corporation, percent: 10, index: i + 1) }

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
        train.buyable = false
      end

      private

      def init_round
        stock_round
      end

      def stock_round
        close_bank_shorts
        @interest_fixed = nil

        Round::G1817::Stock.new(self, [
          Step::DiscardTrain,
          Step::HomeToken,
          Step::G1877::BuySellParShares,
        ])
      end
    end
  end
end
