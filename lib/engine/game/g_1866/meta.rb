# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1866
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        PROTOTYPE = true

        GAME_SUBTITLE = 'The Seven Weeks War'
        GAME_DESIGNER = 'Simon Cutforth'
        GAME_INFO_URL = 'https://google.com'
        GAME_LOCATION = 'Western Europe'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://google.com'

        PLAYER_RANGE = [3, 7].freeze
      end
    end
  end
end
