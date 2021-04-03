# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18Scan
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'David G. D. Hecht'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18SCAN'
        GAME_LOCATION = 'Scandinavia'
        GAME_PUBLISHER = :golden_spike_games
        GAME_RULES_URL = 'http://deepthoughtgames.com/games/18Scan/rules.pdf'

        PLAYER_RANGE = [2, 4].freeze
      end
    end
  end
end
