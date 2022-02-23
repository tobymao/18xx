# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18MO
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha
        PROTOTYPE = true
        DEPENDS_ON = '1846'

        GAME_DESIGNER = 'Scott Petersen'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1852:-Missouri'
        GAME_LOCATION = 'Missouri, USA'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = {
          '1846 Rules' => 'https://s3-us-west-2.amazonaws.com/gmtwebsiteassets/1846/1846-RULES-GMT.pdf',
          '1852: Missouri Rules Differences' => 'https://github.com/tobymao/18xx/wiki/1852:-Missouri',
          'Playtest Forum (BoardGameGeek, best place to discuss)' => 'https://boardgamegeek.com/thread/2814828/1852-missouri-playtesting',
          'Submit Direct Feedback (AAG Contact Form)' => 'https://all-aboardgames.com/pages/order-questions',
        }.freeze
        GAME_TITLE = '1852: Missouri'
        GAME_ALIASES = ['18MO'].freeze

        PLAYER_RANGE = [2, 5].freeze
      end
    end
  end
end
