# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18MT
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha
        PROTOTYPE = true

        GAME_DESIGNER = 'R. Ryan Driskel'
        GAME_LOCATION = 'Montana, USA'
        GAME_TITLE = '18MT: Big Sky Barons'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18MT'

        PLAYER_RANGE = [3, 5].freeze
      end
    end
  end
end
