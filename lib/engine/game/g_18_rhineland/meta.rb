# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18Rhineland
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_SUBTITLE = 'Rhineland 2024'
        GAME_DESIGNER = 'Wolfram Janich'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18Rhl:-Rhineland'
        GAME_LOCATION = 'Rhineland, Germany'
        GAME_PUBLISHER = :marflow_games
        GAME_RULES_URL = 'https://boardgamegeek.com/file/download_redirect/qA9xPkLo8a1m91qcTomfgHRJVWRGbU9tZmhuUFpXV0JXMGVNaERzdDBmb3R4d3g3RTZteEE4eDl1d2c9/18Rhl-LRA+-+Rules+BGG+version.pdf'

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
          {
            sym: :promotion_tiles,
            short_name: 'Promotion Tiles',
            desc: 'Adds some extra tiles.',
          },
          {
            sym: :optional_game_end,
            short_name: 'Optional Game End',
            desc: "Player's banktrupcy will end the game",
          },
          {
            sym: :target_cards,
            short_name: 'Target Cards',
            desc: 'Give each player a target card',
          },
          {
            sym: :destiny_cards,
            short_name: 'Destiny Cards',
            desc: 'Give each player a destiny card',
          },
          {
            sym: :alternative_starting_package,
            short_name: 'Alternative Starting Package',
            desc: 'Five new private companies',
          },
          {
            sym: :short_game,
            short_name: 'Short Game',
            desc: 'Simplified 18xx rules, with player rounds and train rounds',
          },
        ].freeze
        GAME_VARIANTS = [
          {
            sym: :rhl,
            name: 'Rhineland 2012',
            title: '18Rhl',
            desc: '2012 version of 18 Rhineland',
          },
          {
            sym: :lha,
            name: 'Lower Rhine Area',
            title: '18Lha',
            desc: '2-4 player variant of 18 Rhineland (2024)',
          },
        ].freeze
      end
    end
  end
end
