# frozen_string_literal: true

require_relative '../meta'
require_relative '../g_1846/meta'

module Engine
  module Game
    module G1846TwoPlayerVariant
      module Meta
        include Game::Meta
        include G1846::Meta

        DEPENDS_ON = '1846'

        GAME_ALIASES = ['1846 2p'].freeze
        GAME_IS_VARIANT_OF = G1846::Meta
        GAME_RULES_URL = {
          '1846 Rules' => G1846::Meta::GAME_RULES_URL,
          '1846 2p Variant Rules' => 'https://boardgamegeek.com/thread/1616729/draft-2-player-1846-rules-game-designer',
        }.freeze
        GAME_SUBTITLE = nil
        GAME_TITLE = '1846 2p Variant'
        GAME_ISSUE_LABEL = '1846'
        GAME_VARIANTS = [].freeze

        PLAYER_RANGE = [2, 2].freeze
      end
    end
  end
end
