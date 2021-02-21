# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18ChesapeakeOffTheRails
      module Meta
        include Game::Meta

        DEV_STAGE = :beta
        DEPENDS_ON = '18Chesapeake'

        GAME_DESIGNER = 'Scott Petersen'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18Chesapeake'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://www.dropbox.com/s/ivm4jsopnzabhru/18ChesOTR_Rules.png?dl=0'
        GAME_TITLE = '18Chesapeake: Off the Rails'

        PLAYER_RANGE = [2, 6].freeze
      end
    end
  end
end
