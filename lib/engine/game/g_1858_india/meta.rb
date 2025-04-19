# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1858India
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        PROTOTYPE = true
        DEPENDS_ON = '1858'

        GAME_TITLE = '1858India'
        GAME_DISPLAY_TITLE = '1858 India'
        GAME_FULL_TITLE = '1858: The Railways of India'
        GAME_DESIGNER = 'Ian D Wilson'
        GAME_LOCATION = 'India'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1858-India'
        GAME_RULES_URL = 'https://github.com/tobymao/18xx/wiki/1858-India'
        GAME_IMPLEMENTER = 'Oliver Burnett-Hall'
        GAME_ISSUE_LABEL = '1858India'

        PLAYER_RANGE = [3, 6].freeze

        OPTIONAL_RULES = [].freeze
      end
    end
  end
end
