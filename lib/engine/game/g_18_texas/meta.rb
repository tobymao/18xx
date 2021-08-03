# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18Texas
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        PROTOTYPE = true

        GAME_LOCATION = 'Texas, United States'
        GAME_DESIGNER = 'Scott Petersen'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18Texas'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://github.com/tobymao/18xx/wiki/18Texas'

        PLAYER_RANGE = [3, 5].freeze
      end
    end
  end
end
