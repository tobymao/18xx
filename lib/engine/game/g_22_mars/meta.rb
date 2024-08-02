# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G22Mars
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        PROTOTYPE = true

        GAME_DESIGNER = 'Jonas Jones'
        GAME_LOCATION = 'Mars'
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/270966/22mars-rules'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/22Mars'

        PLAYER_RANGE = [3, 5].freeze
      end
    end
  end
end
