# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18EUS
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        PROTOTYPE = true

        GAME_DESIGNER = 'Greg Holton'
        GAME_PUBLISHER = :gmt_games
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18EUS'
        GAME_LOCATION = 'Eastern United States'
        GAME_RULES_URL = ''
        GAME_TITLE = '18EUS'

        PLAYER_RANGE = [3, 5].freeze
      end
    end
  end
end
