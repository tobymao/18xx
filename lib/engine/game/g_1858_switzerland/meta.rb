# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1858Switzerland
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha
        PROTOTYPE = true
        DEPENDS_ON = '1858'

        GAME_TITLE = '1858Switzerland'
        GAME_DISPLAY_TITLE = '1858 Switzerland'
        GAME_FULL_TITLE = '1858: The Railways of Switzerland'
        GAME_DESIGNER = 'Ian D Wilson'
        GAME_LOCATION = 'Switzerland'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1858-Switzerland'
        GAME_RULES_URL = 'https://github.com/tobymao/18xx/wiki/1858-Switzerland'
        GAME_IMPLEMENTER = 'Oliver Burnett-Hall'
        GAME_ISSUE_LABEL = '1858Switzerland'

        PLAYER_RANGE = [2, 4].freeze

        OPTIONAL_RULES = [
          {
            sym: :robot,
            short_name: 'Robot',
            desc: 'Adds a robot player and the SBB national company.',
            players: [2],
          },
        ].freeze
      end
    end
  end
end
