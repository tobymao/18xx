# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18Junta
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        PROTOTYPE = true

        GAME_DESIGNER = 'Leandro Pires'
        GAME_LOCATION = 'Junta (fictional Central America)'
        GAME_RULES_URL = 'https://drive.google.com/file/d/1jOIY8pBolF0xH_4p2UAMrJIrXw9O-pbj/view'

        PLAYER_RANGE = [3, 4].freeze
      end
    end
  end
end
