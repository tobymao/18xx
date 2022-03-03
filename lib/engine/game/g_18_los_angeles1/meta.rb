# frozen_string_literal: true

require_relative '../meta'
require_relative '../g_18_los_angeles/meta'

module Engine
  module Game
    module G18LosAngeles1
      module Meta
        include Game::Meta
        include G18LosAngeles::Meta

        DEV_STAGE = :production
        DEPENDS_ON = '18 Los Angeles 2'

        GAME_PUBLISHER = %i[traxx sea_horse].freeze

        GAME_TITLE = '18 Los Angeles'
        # GAME_IS_VARIANT_OF = G18LosAngeles::Meta
        GAME_ALIASES = ['18LA_1'].freeze
      end
    end
  end
end
