# frozen_string_literal: true

require_relative '../config/game/g_1836jr'
require_relative 'base'

module Engine
  module Game
    class G1836jr < Base
      load_from_json(Config::Game::G1836jr::JSON)

      DEV_STAGE = :alpha
      GAME_LOCATION = nil
      GAME_RULES_URL = 'https://boardgamegeek.com/filepage/114572/1836jr-30-rules'
      GAME_DESIGNER = 'David G. D. Hecht'
    end
  end
end
