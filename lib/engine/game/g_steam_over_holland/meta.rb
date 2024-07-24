# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module GSteamOverHolland
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha

        GAME_TITLE = 'Steam Over Holland'
        GAME_DESIGNER = 'Bart van Dijk'
        GAME_LOCATION = 'The Netherlands'
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/47246/corrected-english-manual-v2'
        GAME_INFO_URL = ''

        PLAYER_RANGE = [2, 5].freeze
      end
    end
  end
end
