# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18West
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_SUBTITLE = 'Rails to the Pacific'
        GAME_DESIGNER = 'David G. D. Hecht'
        GAME_LOCATION = 'Western USA'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18West'
        GAME_PUBLISHER = :all_aboard_games
        # Might be a better one?
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/219096/18west-rules-mass-production-version-2021-03-17'

        PLAYER_RANGE = [2, 6].freeze
      end
    end
  end
end
