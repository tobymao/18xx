# frozen_string_literal: true

require_relative '../meta'
require_relative '../g_1822_pnw/meta'

module Engine
  module Game
    module G1822PnwShort
      module Meta
        include Game::Meta
        include G1822PNW::Meta

        DEV_STAGE = :alpha

        DEPENDS_ON = '1822PNW'
        GAME_IS_VARIANT_OF = G1822PNW::Meta

        GAME_TITLE = '1822PNW Short Scenario'

        PLAYER_RANGE = [3, 5].freeze

        OPTIONAL_RULES = [].freeze
      end
    end
  end
end
