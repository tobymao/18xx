# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G21Moon
      module Meta
        include Game::Meta

        DEV_STAGE = :production
        PROTOTYPE = false

        GAME_DESIGNER = 'Jonas Jones and Scott Petersen'
        GAME_LOCATION = 'The Moon'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/263361/21moon-rules'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/21Moon'

        PLAYER_RANGE = [2, 5].freeze
      end
    end
  end
end
