# frozen_string_literal: true

require_relative '../meta'
require_relative '../g_18_chesapeake/meta'

module Engine
  module Game
    module G18ChristmasEve
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha
        PROTOTYPE = true
        DEPENDS_ON = '18Chesapeake'

        GAME_DESIGNER = 'Lachlan Kingsford'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/Uncle-Lachlan\'s-18-Christmas-Eve'
        GAME_PUBLISHER = :self_published
        GAME_RULES_URL = 'https://www.dropbox.com/s/on6r5df7vf2pjpt/Rules.pdf?dl=0'
        GAME_TITLE = 'Uncle Lachlan\'s 18 Christmas Eve'
        GAME_ISSUE_LABEL = '18 Christmas Eve'

        PLAYER_RANGE = [2, 6].freeze
      end
    end
  end
end
