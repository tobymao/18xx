# frozen_string_literal: true

require_relative '../config/game/g_1882'
require_relative 'base'

module Engine
  module Game
    class G1882 < Base
      register_colors(green: '#237333',
                      gray: '#9a9a9d',
                      red: '#d81e3e',
                      blue: '#0189d1',
                      yellow: '#FFF500',
                      brown: '#7b352a')

      AXES = { x: :number, y: :letter }.freeze
      CORPORATIONS_WITHOUT_NEUTRAL = %w[CPR CN].freeze

      load_from_json(Config::Game::G1882::JSON)

      GAME_LOCATION = 'Assiniboia, Canada'
      GAME_RULES_URL = 'https://www.boardgamegeek.com/filepage/189409/1882-rules'
      GAME_DESIGNER = 'Marc Voyer'
      GAME_PUBLISHER = Publisher::INFO[:all_aboard_games]

      SELL_BUY_ORDER = :sell_buy_sell
      TRACK_RESTRICTION = :permissive

      def init_corporations(stock_market)
        min_price = stock_market.par_prices.map(&:price).min

        corporations = self.class::CORPORATIONS.map do |corporation|
          corporation[:needs_token_to_par] = true if corporation[:sym] == 'CN'
          Corporation.new(
            min_price: min_price,
            capitalization: self.class::CAPITALIZATION,
            **corporation,
          )
        end

        # CN's tokens use a neutral logo, but as layed become owned by cn but don't block other players
        cn_corp = corporations.find { |x| x.name == 'CN' }
        corporations.each do |x|
          unless CORPORATIONS_WITHOUT_NEUTRAL.include?(x.name)
            x.tokens << Token.new(cn_corp, price: 0, logo: '/logos/1882/neutral.svg', type: :neutral)
          end
        end
        corporations
      end
    end
  end
end
