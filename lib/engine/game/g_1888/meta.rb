# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1888
      module Meta
        include Game::Meta

        DEV_STAGE = :production
        PROTOTYPE = true

        GAME_LOCATION = 'North China'
        GAME_DESIGNER = 'Leonhard "Lonny" Orgler'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1888'
        GAME_PUBLISHER = :lonny_games
        GAME_RULES_URL = 'https://github.com/tobymao/18xx/wiki/1888'

        PLAYER_RANGE = [2, 6].freeze
      end
    end
  end
end
