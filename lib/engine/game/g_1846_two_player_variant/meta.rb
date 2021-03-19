# frozen_string_literal: true

require_relative '../meta'
require_relative '../g_1846/meta'

module Engine
  module Game
    module G1846TwoPlayerVariant
      module Meta
        include Game::Meta

        DEV_STAGE = :production
        DEPENDS_ON = '1846'

        GAME_DESIGNER = 'Thomas Lehmann'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1846'
        GAME_LOCATION = 'Midwest, USA'
        GAME_PUBLISHER = %i[gmt_games golden_spike].freeze
        GAME_RULES_URL = {
          '1846 Rules' => 'https://s3-us-west-2.amazonaws.com/gmtwebsiteassets/1846/1846-RULES-GMT.pdf',
          '1846 2p Variant Rules' => 'https://boardgamegeek.com/thread/1616729/draft-2-player-1846-rules-game-designer',
        }.freeze
        GAME_TITLE = '1846 2p Variant'
        GAME_IS_VARIANT_OF = G1846::Meta
        GAME_ALIASES = ['1846 2p'].freeze

        PLAYER_RANGE = [2, 2].freeze
      end
    end
  end
end
