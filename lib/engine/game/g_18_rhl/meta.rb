# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18Rhl
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_SUBTITLE = 'Rhineland'
        GAME_DESIGNER = 'Wolfram Janich'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18Rhl:-Rhineland'
        GAME_LOCATION = 'Rhineland, Germany'
        GAME_PUBLISHER = :marflow_games
        GAME_RULES_URL = 'https://18xx-marflow-games.de/onewebmedia/18Rhl%20-%20Rules%20%20EN.pdf'

        PLAYER_RANGE = [3, 6].freeze
        OPTIONAL_RULES = [
          {
            sym: :optional_2_train,
            short_name: 'Optional 2-Train',
            desc: 'Add a 7th 2-train',
          },
          {
            sym: :lower_starting_capital,
            short_name: 'Lower total Starting Capital',
            desc: 'Reducing the total Starting Capital to 1500M. Recommended only for 3-4 players.',
          },
          {
            sym: :promotion_tiles,
            short_name: 'Promotion Tiles',
            desc: 'Adds some extra tiles.',
          },
          {
            sym: :ratingen_variant,
            short_name: 'Ratingen Variant',
            desc: 'Based on construction of Angertalbahn (Anger valley railway)',
          },
        ].freeze
        GAME_VARIANTS = [
          {
            sym: :rhineland,
            name: 'Rhineland 2024',
            title: '18Rhineland',
            desc: '2024 version of 18 Rhl',
          },
          {
            sym: :lra,
            name: 'Lower Rhineland Area',
            title: '18Lra',
            desc: '2-4 player variant of 18 Rhineland (2024)',
          },
        ].freeze
      end
    end
  end
end
