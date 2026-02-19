# frozen_string_literal: true

require_relative '../meta'
require_relative '../g_18_rhl/meta'

module Engine
  module Game
    module G18Rhineland
      module Meta
        include Game::Meta
        include G18Rhl::Meta

        DEPENDS_ON = '18 Rhl'

        DEV_STAGE = :prealpha

        GAME_IS_VARIANT_OF = G18Rhl::Meta
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18Rhl:-Rhineland-2024'
        GAME_RULES_URL = 'https://boardgamegeek.com/file/download_redirect/qA9xPkLo8a1m91qcTomfgHRJVWRGbU9tZmhuUFpXV0JXMGVNaERzdDBmb3R4d3g3RTZteEE4eDl1d2c9/18Rhl-LRA+-+Rules+BGG+version.pdf'
        GAME_TITLE = 'Rhineland 2024'

        PLAYER_RANGE = [3, 5].freeze
        OPTIONAL_RULES = [
          {
            sym: :optional_2_train,
            short_name: 'Optional 2-Train',
            desc: 'Add a 7th 2-train',
          },
          {
            sym: :lower_starting_capital,
            short_name: 'Lower Total Starting Capital',
            desc: 'Reducing the total Starting Capital to 1500M. Recommended only for 3-4 players.',
          },
          # Not yet implemented
          # {
          #   sym: :optional_game_end,
          #   short_name: 'Optional Game End',
          #   desc: "Player's banktrupcy will end the game",
          # },
          # {
          #   sym: :target_cards,
          #   short_name: 'Target Cards',
          #   desc: 'Give each player a target card',
          # },
          # {
          #   sym: :destiny_cards,
          #   short_name: 'Destiny Cards',
          #   desc: 'Give each player a destiny card',
          # },
          # {
          #   sym: :alternative_starting_package,
          #   short_name: 'Alternative Starting Package',
          #   desc: 'Five new private companies',
          # },
          # {
          #   sym: :short_game,
          #   short_name: 'Short Game',
          #   desc: 'Simplified 18xx rules, with player rounds and train rounds',
          # },
          # {
          #   sym: :optional_chose_rhe_par_value,
          #   short_name: 'Chose RHE Par Value',
          #   desc: "Player that wins RHE private can chose the par value of RHE",
          # },
        ].freeze
      end
    end
  end
end
