# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18ESP
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_SUBTITLE = 'Spain'
        GAME_DESIGNER = 'Lonny Orgler and Enrique Trigueros'
        GAME_LOCATION = 'Spain'
        GAME_PUBLISHER = nil
        GAME_RULES_URL = ''
        GAME_INFO_URL = ''

        PLAYER_RANGE = [3, 6].freeze
      end
    end
  end
end
