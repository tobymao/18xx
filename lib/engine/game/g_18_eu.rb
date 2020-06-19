# frozen_string_literal: true

require_relative '../config/game/g_18_eu'
require_relative 'base'

module Engine
  module Game
    class G18EU < Base
      load_from_json(Config::Game::G18EU::JSON)

      GAME_LOCATION = 'Europe'
      GAME_DESIGNER = 'David Hecht'
    end
  end
end
