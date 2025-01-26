# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1837
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha

        GAME_DESIGNER = 'Leonhard Orgler'
        GAME_LOCATION = 'Eastern Europe'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/238953'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1837'

        PLAYER_RANGE = [3, 7].freeze
      end
    end
  end
end
