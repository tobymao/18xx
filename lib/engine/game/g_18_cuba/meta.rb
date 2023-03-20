# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18Cuba
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'Leonhard "Lonny" Orgler'
        GAME_LOCATION = 'Cuba'
        GAME_PUBLISHER = :lonny_games

        PLAYER_RANGE = [2, 6].freeze
      end
    end
  end
end
