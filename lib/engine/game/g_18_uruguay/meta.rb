# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18Uruguay
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        PROTOTYPE = true

        GAME_DESIGNER = 'Pontus Nilsson'
        GAME_LOCATION = 'Uruguay'
        GAME_PUBLISHER = :self_published
        GAME_RULES_URL = 'https://boardgamegeek.com/file/download_redirect/35ac0b10c5ac19b363b82a4b572fb2a3d72b482baa0a61e4/18Uruguay_rules-0978.pdf'
        GAME_INFO_URL = ''

        PLAYER_RANGE = [3, 6].freeze
        OPTIONAL_RULES = [].freeze
      end
    end
  end
end
