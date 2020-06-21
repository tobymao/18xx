# frozen_string_literal: true

require_relative '../config/game/g_1836_jr30'
require_relative 'base'

module Engine
  module Game
    class G1836Jr30 < Base
      load_from_json(Config::Game::G1836Jr30::JSON)

      DEV_STAGE = :alpha
      GAME_LOCATION = 'Netherlands'
      GAME_RULES_URL = 'https://boardgamegeek.com/filepage/114572/1836jr-30-rules'
      GAME_DESIGNER = 'David G. D. Hecht'

      SELL_BUY_ORDER = :sell_buy_sell

      TILE_RESERVATION_BLOCKS_OTHERS = true
    end
  end
end
