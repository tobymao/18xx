# frozen_string_literal: true

require_relative '../meta'
require_relative '../g_18_oe/meta'

module Engine
  module Game
    module G18OEUKFR
      module Meta
        include Game::Meta
        include G18OE::Meta

        DEPENDS_ON = '18OE'.freeze
        GAME_IS_VARIANT_OF = G18OE::Meta

        # GAME_PUBLISHER = ''
        # GAME_RULES_URL = ''
        GAME_TITLE = '18OE UK-France Scenario'.freeze
        # GAME_VARIANTS = [].freeze
        GAME_ISSUE_LABEL = '18OE'
        PLAYER_RANGE = [2, 3].freeze

        def self.fs_name
          @fs_name ||= 'g_18_oe_uk_fr'
        end
      end
    end
  end
end
