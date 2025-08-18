# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18Uruguay
      module Meta
        include Game::Meta

        DEV_STAGE = :beta
        PROTOTYPE = true

        GAME_DESIGNER = 'Pontus Nilsson'
        GAME_LOCATION = 'Uruguay'
        GAME_PUBLISHER = :self_published
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/264279/18uruguay-english-rules'
        GAME_INFO_URL = ''

        PLAYER_RANGE = [3, 6].freeze
        OPTIONAL_RULES = [].freeze
      end
    end
  end
end
