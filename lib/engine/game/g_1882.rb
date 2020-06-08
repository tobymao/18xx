# frozen_string_literal: true

require_relative '../config/game/g_1882'
require_relative 'base'
require_relative '../neutral_token'

module Engine
  module Game
    class G1882 < Base
      register_colors(green: '#237333',
                      gray: '#9a9a9d',
                      red: '#d81e3e',
                      blue: '#0189d1',
                      yellow: '#FFF500',
                      brown: '#7b352a')

      CORPORATIONS_WITHOUT_NEUTRAL = %w[CPR CN].freeze

      load_from_json(Config::Game::G1882::JSON)

      def stock_round
        Round::Stock.new(@players, game: self, sell_buy_order: :sell_buy_sell)
      end

      def init_corporations(stock_market)
        corporations = super
        corporations.each do |x|
          unless CORPORATIONS_WITHOUT_NEUTRAL.include?(x.name)
            x.tokens << NeutralToken.new('/logos/1882/neutral.svg', price: 0)
          end
        end
        corporations
      end
    end
  end
end
