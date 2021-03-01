# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18FL
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'David Hecht'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18FL'
        GAME_LOCATION = 'Florida, US'
        GAME_RULES_URL = 'http://google.com'

        PLAYER_RANGE = [2, 4].freeze
      end
    end
  end
end
