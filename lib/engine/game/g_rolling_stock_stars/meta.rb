# frozen_string_literal: true

require_relative '../meta'
require_relative '../g_18_new_england/meta'

module Engine
  module Game
    module GRollingStockStars
      module Meta
        include Game::Meta
        include GRollingStock::Meta

        DEV_STAGE = :alpha
        DEPENDS_ON = 'RollingStock'

        GAME_ALIASES = ['Rolling Stock Stars'].freeze
        GAME_IS_VARIANT_OF = GRollingStock::Meta
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/Rolling-Stock'
        GAME_RULES_URL = 'https://github.com/beorn7/rolling_stock/blob/master/rules.pdf'
        GAME_SUBTITLE = nil
        GAME_TITLE = 'Rolling Stock Stars'

        PLAYER_RANGE = [2, 6].freeze

        OPTIONAL_RULES = [].freeze
      end
    end
  end
end
