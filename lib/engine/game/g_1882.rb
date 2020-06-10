# frozen_string_literal: true

require_relative '../config/game/g_1882'
require_relative 'base'
require_relative '../publisher'

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

      GAME_LOCATION = 'Assiniboia, Canada'
      GAME_RULES_URL = 'https://www.boardgamegeek.com/filepage/189409/1882-rules'
      GAME_DESIGNER = 'Marc Voyer'
      GAME_PUBLISHER = Publisher::INFO[:all_aboard_games]

      def stock_round
        Round::Stock.new(@players, game: self, sell_buy_order: :sell_buy_sell)
      end

      def init_corporations(stock_market)
        # Neutral corp that allows tokens that don't block other players
        # CN runs using these tokens
        neutral_corp = Corporation.new(sym: 'neutral', name: 'neutral', tokens: [], logo: '1882/neutral')
        corporations = super
        corporations.each do |x|
          x.tokens << Token.new(neutral_corp, price: 0) unless CORPORATIONS_WITHOUT_NEUTRAL.include?(x.name)
        end
        corporations
      end
    end
  end
end
