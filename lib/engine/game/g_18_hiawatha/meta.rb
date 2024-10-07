# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18Hiawatha
      module Meta
        include Game::Meta

        DEV_STAGE = :beta
        DEPENDS_ON = '1817'

        GAME_DESIGNER = 'Michael Carter, Anthony Fryer, & Nick Neylon'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18Hiawatha'
        GAME_LOCATION = 'Midwest USA'
        GAME_TITLE = '18 Hiawatha'
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/279677/18-hiawatha-rules-from-mainline-issue-1'

        PLAYER_RANGE = [3, 6].freeze

        OPTIONAL_RULES = [
          {
            sym: :no_privates,
            short_name: 'No privates',
            desc: 'This variant removes all private companies from the game.',
          },
        ].freeze
      end
    end
  end
end
