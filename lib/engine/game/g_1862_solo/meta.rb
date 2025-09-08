# frozen_string_literal: true

require_relative '../meta'
require_relative '../g_1862/meta'

module Engine
  module Game
    module G1862Solo
      module Meta
        include Game::Meta
        include G1862::Meta

        DEPENDS_ON = '1862'

        DEV_STAGE = :prealpha

        GAME_IS_VARIANT_OF = G1862::Meta
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1862'.freeze
        GAME_TITLE = '1862 Solo'.freeze

        PLAYER_RANGE = [1, 1].freeze
        OPTIONAL_RULES = [].freeze
      end
    end
  end
end
