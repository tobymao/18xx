# frozen_string_literal: true

require_relative '../meta'
require_relative '../g_1880_romania/meta'

module Engine
  module Game
    module G1880RomaniaRegatul
      module Meta
        include Game::Meta
        include G1880Romania::Meta

        DEPENDS_ON = '1880 Romania'

        DEV_STAGE = :prealpha

        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1880-Romania-Regatul-map'.freeze
        GAME_TITLE = '1880 Regatul României'.freeze
        GAME_SUBTITLE = '1880 Kingdom of Romania'

        PLAYER_RANGE = [2, 3].freeze
      end
    end
  end
end
