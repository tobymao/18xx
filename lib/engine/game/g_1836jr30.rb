# frozen_string_literal: true

require_relative '../config/game/g_1836jr30'
require_relative 'base'

module Engine
  module Game
    class G1836jr30 < Base
      load_from_json(Config::Game::G1836jr30::JSON)

      DEV_STAGE = :alpha
      GAME_LOCATION = 'Netherlands'
      GAME_RULES_URL = 'https://boardgamegeek.com/filepage/114572/1836jr-30-rules'
      GAME_DESIGNER = 'David G. D. Hecht'

      def stock_round
        Round::Stock.new(@players, game: self, sell_buy_order: :sell_buy_sell)
      end
    end
  end
end
