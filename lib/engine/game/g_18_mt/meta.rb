# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18MT
      module Meta
        include Game::Meta

        DEV_STAGE = :production
        PROTOTYPE = true

        GAME_DESIGNER = 'R. Ryan Driskel'
        GAME_LOCATION = 'Montana, USA'
        GAME_TITLE = '18MT: Big Sky Barons'
        GAME_ISSUE_LABEL = '18MT'
        GAME_RULES_URL = {
          'Wiki Rules Highlights' => 'https://github.com/tobymao/18xx/wiki/18MT:-Big-Sky-Barons',
          'Contact Ryan on the 18xx Slack' => 'https://app.slack.com/client/T67762LUR/C012K0CNY5C',
          'Playtest Forum (BoardGameGeek, best place to discuss)' => 'https://boardgamegeek.com/thread/2816504/18mt-big-sky-barons-playtesting',
        }.freeze
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18MT:-Big-Sky-Barons'

        PLAYER_RANGE = [3, 5].freeze
      end
    end
  end
end
