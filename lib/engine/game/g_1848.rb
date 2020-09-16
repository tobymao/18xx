# frozen_string_literal: true

require_relative '../config/game/g_1848'
require_relative 'base'

module Engine
  module Game
    class G1848 < Base
      load_from_json(Config::Game::G1848::JSON)

      GAME_LOCATION = 'Australia'
      GAME_RULES_URL = 'http://ohley.de/english/1848/1848-rules.pdf'
      GAME_DESIGNER = 'Leonhard Orgler and Helmut Ohley'
      #GAME_PUBLISHER = Publisher::INFO[:oo_games]
      #GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1848'

    end
  end
end
