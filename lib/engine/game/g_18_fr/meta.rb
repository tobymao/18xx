# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18FR
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        DEPENDS_ON = '1817'

        GAME_DESIGNER = 'Alex Rockwell'
        GAME_IMPLEMENTER = 'Jan Kłos'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18FR'
        GAME_LOCATION = 'France'
        GAME_RULES_URL = ''

        PLAYER_RANGE = [3, 6].freeze
      end
    end
  end
end
