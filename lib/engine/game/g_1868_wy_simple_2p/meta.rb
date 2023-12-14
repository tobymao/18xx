# frozen_string_literal: true

require_relative '../meta'
require_relative '../g_1868_wy/meta'

module Engine
  module Game
    module G1868WYSimple2p
      module Meta
        include Game::Meta
        include G1868WY::Meta

        DEPENDS_ON = '1868 Wyoming'

        GAME_ALIASES = ['1868 Wyoming 2p'].freeze
        GAME_IS_VARIANT_OF = G1868WY::Meta
        GAME_SUBTITLE = nil
        GAME_TITLE = '1868 Wyoming Simple 2p'
        GAME_ISSUE_LABEL = '1868WY'
        GAME_VARIANTS = [].freeze

        PLAYER_RANGE = [2, 2].freeze

        def self.fs_name
          'g_1868_wy_simple_2p'
        end
      end
    end
  end
end
