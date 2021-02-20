# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1893
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'Edwin Eckert'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1893'
        GAME_LOCATION = 'Cologne, Germany'
        GAME_PUBLISHER = :marflow_games
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/188718/1893-cologne-rule-summary-version-10'

        PLAYER_RANGE = [2, 4].freeze
        OPTIONAL_RULES = [
          {
            sym: :optional_2_train,
            short_name: 'Optional 2-Train',
            desc: 'Add an 8th 2-train',
          },
          {
            sym: :optional_grey_phase,
            short_name: 'Gray Phase',
            desc: 'Changed Köln tiles. Extra gray KV259.',
          },
          {
            sym: :optional_existing_track,
            short_name: 'Existing Track',
            desc: 'E2 and D7 start as yellow. New S upgrades.',
          },
        ].freeze
      end
    end
  end
end
