# frozen_string_literal: true

require_relative '../meta'
require_relative '../g_18_chesapeake/meta'

module Engine
  module Game
    module G18ChesapeakeOffTheRails
      module Meta
        include Game::Meta

        DEV_STAGE = :production
        DEPENDS_ON = '18Chesapeake'

        GAME_DESIGNER = 'Scott Petersen'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18Chesapeake'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://www.dropbox.com/s/ivm4jsopnzabhru/18ChesOTR_Rules.png?dl=0'
        GAME_TITLE = '18Chesapeake: Off the Rails'
        GAME_ALIASES = %w[OTR 18ChesapeakeOTR].freeze
        GAME_IS_VARIANT_OF = G18Chesapeake::Meta
        GAME_ISSUE_LABEL = '18Chesapeake'

        PLAYER_RANGE = [2, 6].freeze
      end
    end
  end
end
