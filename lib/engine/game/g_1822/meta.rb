# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1822
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'Simon Cutforth'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1822'
        GAME_LOCATION = 'Great Britain'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'http://google.com'

        PLAYER_RANGE = [3, 7].freeze
      end
    end
  end
end
