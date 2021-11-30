# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18USA
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        DEPENDS_ON = '1817'

        GAME_DESIGNER = 'Edward Reece, Mark Hendrickson, and Shawn Fox'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18USA'
        GAME_LOCATION = 'United States'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = {
          '18USA' => 'https://boardgamegeek.com/filepage/145024/18usa-rules',
          '1817 Rules' =>
                'https://drive.google.com/file/d/0B1SWz2pNe2eAbnI4NVhpQXV4V0k/view',
        }.freeze
        GAME_TITLE = '18USA'

        PLAYER_RANGE = [2, 7].freeze
      end
    end
  end
end
