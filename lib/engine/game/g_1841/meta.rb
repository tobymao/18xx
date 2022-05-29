# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1841
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_SUBTITLE = nil
        GAME_DESIGNER = 'Federico Vallani and Manlio Manzini'
        GAME_LOCATION = 'Northern Italy'
        GAME_PUBLISHER = :deep_thought_games
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/170630/1841-rules'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1841'

        PLAYER_RANGE = [3, 8].freeze
        OPTIONAL_RULES = [].freeze
      end
    end
  end
end
