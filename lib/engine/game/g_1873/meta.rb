# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1873
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_DESIGNER = 'Klaus Kiermeier'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/Harzbahn-1873'
        GAME_LOCATION = 'Germany'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/238954/harzbahn-1873-rules-2022-all-aboard-games'
        GAME_TITLE = 'Harzbahn 1873'
        FIXTURE_DIR_NAME = '1873'

        PLAYER_RANGE = [2, 5].freeze
        OPTIONAL_RULES = [
          {
            sym: :aag_variant,
            short_name: 'All-Aboard Games map',
            desc: 'Hex F7 has a 100 ℳ terrain cost instead of 50 ℳ',
          },
        ].freeze
      end
    end
  end
end
