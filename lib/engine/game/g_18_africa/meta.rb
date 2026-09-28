# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18Africa
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_TITLE = '18Africa'
        GAME_DESIGNER = 'Jeff Edmunds'
        GAME_LOCATION = 'Africa'
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/116302/rules'
        GAME_ISSUE_LABEL = '18Africa'

        PLAYER_RANGE = [2, 5].freeze
      end
    end
  end
end
