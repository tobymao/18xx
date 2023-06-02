# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1860
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_SUBTITLE = 'Railways on the Isle of Wight'
        GAME_DESIGNER = 'Mike Hutton'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1860'
        GAME_LOCATION = 'Isle of Wight'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://www.dropbox.com/s/usfbqtdjzx6ug8f/1860-rules.pdf'

        PLAYER_RANGE = [2, 4].freeze
        OPTIONAL_RULES = [
          {
            sym: :two_player_map,
            short_name: '2-3P map',
            desc: 'Use the smaller first edition map suitable for 2-3 players',
          },
          {
            sym: :original_insolvency,
            short_name: 'Original insolvency',
            desc: 'Use the original (first edition) insolvency rules',
          },
          {
            sym: :no_skip_towns,
            short_name: 'No skipping towns',
            desc: "Use the original (first edition) town rules - they can't be skipped on runs",
          },
          {
            sym: :original_game,
            short_name: 'First edition rules and map',
            desc: 'Use all of the first edition rules (smaller map, original insolvency, no skipping towns)',
          },
          {
            sym: :re_enter_hexes,
            short_name: 'Re-enter hexes',
            desc: 'Routes may enter the same hex more than once, so long as no track is re-used.',
          },
        ].freeze
      end
    end
  end
end
