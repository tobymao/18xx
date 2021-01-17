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
      GAME_PUBLISHER = :all_aboard_games
      GAME_LOCATION = 'Venezuela'

      DEV_STAGE = :prealpha

      SELL_AFTER = :any_time

      def size_corporation(corporation, size)
        return unless size == 10
        raise GameError, 'Can only convert 5 share corporation' unless corporation.total_shares == 5

        original_shares = @_shares.values.select { |share| share.corporation == corporation }

        corporation.share_holders.clear
        original_shares[0].percent = 20
        shares = 8.times.map { |i| Share.new(corporation, percent: 10, index: i + 1) }
        original_shares.each { |share| corporation.share_holders[share.owner] += share.percent }

        shares.each do |share|
          add_new_share(share)
        end
      end

      def float_corporation(corporation)
        @log << "#{corporation.name} floats and transfers remaining shares to the market"
        @bank.spend((corporation.par_price.price * corporation.total_shares) / 2, corporation)
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
