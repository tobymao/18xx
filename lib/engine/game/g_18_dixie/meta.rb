# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18Dixie
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_SUBTITLE = 'The Railroads Come to the Deep South'
        GAME_DESIGNER = 'Mark Derrick'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18Dixie'
        GAME_LOCATION = 'USA South'
        GAME_PUBLISHER = :golden_spike
        GAME_RULES_URL = 'https://18xx.games' # TODO: Make a stable rules link

        PLAYER_RANGE = [3, 6].freeze
      end
    end
  end
end
