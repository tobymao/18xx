# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1866
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        PROTOTYPE = true

        GAME_SUBTITLE = 'Railways of Europe'
        GAME_DESIGNER = 'Simon Cutforth'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1866'
        GAME_LOCATION = 'Western Europe'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://google.com'

        PLAYER_RANGE = [3, 7].freeze
        OPTIONAL_RULES = [
          {
            sym: :nes,
            short_name: 'NES',
            desc: 'North Europe Scenario (GB FR BNL CH DE)',
          },
          {
            sym: :ces,
            short_name: 'CES',
            desc: 'Central Europe Scenario (BNL CH AHE DE I)',
          },
          {
            sym: :ses,
            short_name: 'SES',
            desc: 'South Europe Scenario (FR ESP CH AHE IT)',
          },
        ].freeze

        MUTEX_RULES = [
          %i[nes ces ses],
        ].freeze
      end
    end
  end
end
