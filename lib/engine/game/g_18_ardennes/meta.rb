# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18Ardennes
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'David Hecht'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18Ardennes'
        GAME_LOCATION = 'Belguim, the Netherlands, Germany and France'
        GAME_PUBLISHER = :deep_thought_games
        GAME_RULES_URL = 'https://drive.google.com/file/d/1ac2WuCiXRSr9lHpTkkR1yWK0l5cbBu2o/view'

        PLAYER_RANGE = [3, 5].freeze
      end
    end
  end
end
