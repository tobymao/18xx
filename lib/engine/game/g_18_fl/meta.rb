# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18FL
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha

        GAME_SUBTITLE = 'Railroads to Paradise'
        GAME_DESIGNER = 'David Hecht'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18FL'
        GAME_LOCATION = 'Florida, US'
        GAME_RULES_URL = 'https://www.deepthoughtgames.com/games/18FL/Rules.pdf'

        PLAYER_RANGE = [2, 4].freeze
      end
    end
  end
end
