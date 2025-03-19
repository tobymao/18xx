# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18Ardennes
      module Meta
        include Game::Meta

        DEV_STAGE = :beta

        GAME_TITLE = '18Ardennes'
        GAME_SUBTITLE = 'Rails Through the Ardennes'
        GAME_DESIGNER = 'David G D Hecht'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18Ardennes'
        GAME_LOCATION = 'Northwestern Europe'
        GAME_PUBLISHER = :deep_thought_games
        GAME_RULES_URL = 'https://drive.google.com/file/d/1ac2WuCiXRSr9lHpTkkR1yWK0l5cbBu2o/view'
        GAME_IMPLEMENTER = 'Oliver Burnett-Hall'
        KEYWORDS = %w[Belgium Netherlands France Germany].freeze

        PLAYER_RANGE = [3, 5].freeze
      end
    end
  end
end
