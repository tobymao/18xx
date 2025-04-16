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
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/238952/third-edition-rules'

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
            sym: :simplified_insolvency,
            short_name: 'Simplified insolvency',
            desc: 'Insolvent corporations run trains for fixed amounts',
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
          {
            sym: :non_operated_full_value,
            short_name: 'Non-operated shares worth full value',
            desc: 'Shares of unoperated corps sell for full value',
          },
        ].freeze

        def self.check_options(options, _min_players, _max_players)
          optional_rules = (options || []).map(&:to_sym)

          if optional_rules.include?(:simplified_insolvency) &&
             (optional_rules.include?(:original_insolvency) ||
              optional_rules.include?(:original_game))
            { error: "Can't combine Simplified Insolvency with Original Insolvency or First edition rules" }
          end
        end
      end
    end
  end
end
