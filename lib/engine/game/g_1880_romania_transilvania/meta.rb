# frozen_string_literal: true

require_relative '../meta'
require_relative '../g_1880_romania/meta'

module Engine
  module Game
    module G1880RomaniaTransilvania
      module Meta
        include Game::Meta
        include G1880Romania::Meta

        DEPENDS_ON = '1880 Romania'

        DEV_STAGE = :prealpha

        # This does not seem to work, this variant do not appear under 1880 Romania
        # GAME_IS_VARIANT_OF = G1880Romania::Meta

        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1880-Romania-Transilvania-map'.freeze
        GAME_TITLE = '1880 Romania Transilvania'.freeze

        PLAYER_RANGE = [2, 2].freeze
        OPTIONAL_RULES = [].freeze
      end
    end
  end
end
