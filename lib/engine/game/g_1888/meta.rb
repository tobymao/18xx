# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1888
      module Meta
        include Game::Meta

        # DEV_STAGE = :alpha

        GAME_DESIGNER = 'Leonhard "Lonny" Orgler'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1888'
        GAME_PUBLISHER = :lonny_games
        GAME_RULES_URL = ''

        PLAYER_RANGE = [2, 6].freeze
      end
    end
  end
end
