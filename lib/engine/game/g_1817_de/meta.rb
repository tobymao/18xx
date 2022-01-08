# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1817DE
      module Meta
        include Game::Meta

        DEV_STAGE = :production
        PROTOTYPE = true
        DEPENDS_ON = '1817'

        GAME_DESIGNER = 'Scott Petersen'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18DE'
        GAME_LOCATION = 'Germany'
        GAME_RULES_URL = {
          '18DE Rule Differences' =>
                          'https://docs.google.com/document/d/1lH3TcQc6etptZDWMbX1oZe7ne2VbbinAYkX8W_lpu-c/edit',
          '18DE Playtest Feedback (BGG)' =>
                          'https://boardgamegeek.com/thread/2640741/article/37490722',
          '1817 Rules' =>
                'https://drive.google.com/file/d/0B1SWz2pNe2eAbnI4NVhpQXV4V0k/view',
        }.freeze
        GAME_TITLE = '18DE'

        PLAYER_RANGE = [2, 6].freeze
        OPTIONAL_RULES = [
          {
            sym: :modern_trains,
            short_name: 'Modern Trains',
            desc: '7 & 8 trains earn 10 ℳ & 20 ℳ respectively for each station marker of the corporation',
          },
        ].freeze
      end
    end
  end
end
