# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1835
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'Michael Meier-Bachl, Francis Tresham'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1835'
        GAME_LOCATION = 'Germany'
        GAME_RULES_URL = 'https://boardgamegeek.com/wiki/page/1835_Rules'

        PLAYER_RANGE = [3, 7].freeze
        OPTIONAL_RULES = [
          {
            sym: :vanderpluym,
            short_name: 'Vanderpluym-Auktion',
            desc: 'Each start packet item is auctioned with a minimum bid (5M increments); '\
                  'BY floats when president\'s share is purchased',
          },
          {
            sym: :clemens,
            short_name: 'Clemens-Variante',
            desc: 'All start packet items available from the start; draft order reversed for first circuit '\
                  '(4-3-2-1-1-2-3-4...); BY floats when president\'s share is purchased',
          },

        ].freeze

        def self.check_options(options, _min_players, _max_players)
          selected = (options || []).map(&:to_sym)
          return unless (selected & %i[clemens vanderpluym]).length == 2

          { error: 'Clemens-Variante and Vanderpluym-Auktion cannot be used together' }
        end
      end
    end
  end
end
