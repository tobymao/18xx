# frozen_string_literal: true

require_relative '../meta'
require_relative '../g_1824/meta'

module Engine
  module Game
    module G1824Cisleithania
      module Meta
        include Game::Meta
        include G1824::Meta

        DEPENDS_ON = '1824'

        DEV_STAGE = :prealpha

        GAME_IS_VARIANT_OF = G1824::Meta
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1824-Cisleithania-map'.freeze
        GAME_TITLE = '1824 Cisleithania'.freeze

        PLAYER_RANGE = [2, 3].freeze
        OPTIONAL_RULES = [].freeze
      end
    end
  end
end
