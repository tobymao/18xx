# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18NewEngland
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'Scott Petersen'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18NewEngland'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://www.dropbox.com/s/x0dsehrxqr1tl6w/18Chesapeake_Rules.pdf'
        GAME_VARIANTS = [
          sym: :north,
          name: '18NewEngland 2',
          title: '18NewEngland 2: Northern States',
          desc: 'smaller map and player count',
        ].freeze

        PLAYER_RANGE = [3, 5].freeze
      end
    end
  end
end
