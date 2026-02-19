# frozen_string_literal: true

require_relative '../meta'
require_relative '../g_18_rhl/meta'

module Engine
  module Game
    module G18Lra
      module Meta
        include Game::Meta
        include G18Rhl::Meta

        DEPENDS_ON = '18 Rhl'

        DEV_STAGE = :prealpha

        GAME_IS_VARIANT_OF = G18Rhl::Meta
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18LRA%3A-Lower-Rhineland-Area'
        GAME_TITLE = '18Lra'
        GAME_SUBTITLE = 'Lower Rhineland Area'

        PLAYER_RANGE = [2, 4].freeze
        OPTIONAL_RULES = [
          {
            sym: :optional_2_train,
            short_name: 'Optional 2-Train',
            desc: 'Add a 6th 2-train',
          },
          {
            sym: :lower_starting_capital,
            short_name: 'Lower total Starting Capital',
            desc: 'Reducing the total Starting Capital to 1500M.',
          },
          # Not yet implemented
          # {
          #   sym: :optional_game_end,
          #   short_name: 'Optional Game End',
          #   desc: "Player's banktrupcy will end the game",
          # },
          # {
          #   sym: :short_game,
          #   short_name: 'Short Game',
          #   desc: 'Simplified 18xx rules, with player rounds and train rounds',
          # },
        ].freeze
      end
    end
  end
end
