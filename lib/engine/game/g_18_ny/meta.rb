# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18NY
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        DEPENDS_ON = '1849' # probably only while in development

        GAME_DESIGNER = 'Pierre LeBoeuf'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18NY'
        GAME_LOCATION = 'New York, USA'
        GAME_RULES_URL = 'https://drive.google.com/open?id=0B1SWz2pNe2eAWG9NRVYzS3FUc28'
        GAME_TITLE = '18NY'

        PLAYER_RANGE = [2, 6].freeze
      end
    end
  end
end
