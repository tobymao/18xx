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

      CORPORATIONS_OVERRIDE = {
        'CN' => {
          needs_token_to_par: true,
        },
      }.freeze

      load_from_json(Config::Game::G1882::JSON)

      GAME_LOCATION = 'Assiniboia, Canada'
      GAME_RULES_URL = 'https://www.boardgamegeek.com/filepage/189409/1882-rules'
      GAME_DESIGNER = 'Marc Voyer'
      GAME_PUBLISHER = Publisher::INFO[:all_aboard_games]

      TRACK_RESTRICTION = :permissive

      def stock_round
        Round::Stock.new(@players, game: self, sell_buy_order: :sell_buy_sell)
      end

      def init_corporations(stock_market)
        corporations = super
        # CN's tokens use a neutral logo, but as layed become owned by cn but don't block other players
        cn_corp = corporations.find { |x| x.name == 'CN' }
        corporations.each do |x|
          unless CORPORATIONS_WITHOUT_NEUTRAL.include?(x.name)
            x.tokens << Token.new(cn_corp, price: 0, logo: '/logos/1882/neutral.svg')
          end
        end
        corporations
      end

      def operating_round(round_num)
        Round::G1882::Operating.new(@corporations, game: self, round_num: round_num)
      end
    end
  end
end
