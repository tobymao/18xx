# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1880Romania
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        DEPENDS_ON = '1880'

        GAME_DESIGNER = 'Lonny Orgler'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1880-Romania' # todo
        GAME_LOCATION = 'Romania'
        GAME_PUBLISHER = :lonny_games
        GAME_RULES_URL = # todo
          GAME_TITLE = '1880 Romania'

        PLAYER_RANGE = [3, 6].freeze
      end
    end
  end
end
