# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1847AE
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_TITLE = '1847 AE'
        GAME_SUBTITLE = 'Pfalz - Anniversary Edition'
        GAME_DESIGNER = 'Wolfram Janich'
        GAME_IMPLEMENTER = 'Jan Kłos'
        GAME_LOCATION = 'Pfalz, Germany'
        GAME_PUBLISHER = :marflow_games
        GAME_RULES_URL = ''
        GAME_INFO_URL = ''

        PLAYER_RANGE = [3, 5].freeze
      end
    end
  end
end
