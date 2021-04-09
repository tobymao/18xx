# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1835
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'Michael Meier-Bachl, Francis Tresham'
        GAME_INFO_URL = 'https://google.com'
        GAME_LOCATION = 'Germany'
        GAME_RULES_URL = 'http://google.com'

        PLAYER_RANGE = [3, 7].freeze
        OPTIONAL_RULES = [
          {
            sym: :clemens,
            short_name: 'Clemens-Variante',
            desc: 'all Privates and minors are available, Playerorder for the SR 4-3-2-1-1-2-3-4-1-2-3-4, '\
                  'Minors start when Bayerische Eisenbahn floats',
          },
        ].freeze
      end
    end
  end
end
