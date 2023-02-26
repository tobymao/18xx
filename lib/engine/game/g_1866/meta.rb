# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1866
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha
        PROTOTYPE = true

        GAME_SUBTITLE = 'Railways of Europe'
        GAME_DESIGNER = 'Simon Cutforth'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1866'
        GAME_LOCATION = 'Western Europe'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://docs.google.com/document/d/1EH8REWBU68orMZI8M_cZ0Kc8v65YXb1l_ogSEzlz93g'

        PLAYER_RANGE = [3, 6].freeze
        OPTIONAL_RULES = [
          {
            sym: :ces,
            short_name: 'CES',
            desc: 'Central Europe Scenario (BNL CH AHE DE IT)',
          },
        ].freeze

        MUTEX_RULES = [
          %i[nes ces ses],
        ].freeze
      end
    end
  end
end
