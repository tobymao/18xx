# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18Norway
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        PROTOTYPE = true

        GAME_DESIGNER = 'Pontus Nilsson and Kjell Vikhagen'
        GAME_LOCATION = 'Norway'
        GAME_PUBLISHER = :self_published
        GAME_RULES_URL = ''
        GAME_INFO_URL = ''

        PLAYER_RANGE = [3, 5].freeze
        OPTIONAL_RULES = [].freeze
      end
    end
  end
end
