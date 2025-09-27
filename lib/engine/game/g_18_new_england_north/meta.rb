# frozen_string_literal: true

require_relative '../meta'
require_relative '../g_18_new_england/meta'

module Engine
  module Game
    module G18NewEnglandNorth
      module Meta
        include Game::Meta
        include G18NewEngland::Meta

        DEV_STAGE = :production
        PROTOTYPE = true
        DEPENDS_ON = '18NewEngland'

        GAME_ALIASES = ['18NewEngland 2'].freeze
        GAME_IS_VARIANT_OF = G18NewEngland::Meta
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18NewEngland-2:-Northern-States'
        GAME_RULES_URL = 'https://github.com/tobymao/18xx/wiki/18NewEngland-2:-Northern-States'
        GAME_SUBTITLE = nil
        GAME_TITLE = '18NewEngland 2: Northern States'
        FIXTURE_DIR_NAME = '18NewEngland2'
        GAME_ISSUE_LABEL = '18NewEngland'

        PLAYER_RANGE = [2, 4].freeze
      end
    end
  end
end
