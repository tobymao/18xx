# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module GRollingStock
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_SUBTITLE = ''
        GAME_DESIGNER = 'Björn Rabenstein'
        GAME_LOCATION = 'n/a'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://github.com/beorn7/rolling_stock/blob/master/rules.pdf'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/RollingStock'

        PLAYER_RANGE = [2, 6].freeze
      end
    end
  end
end
