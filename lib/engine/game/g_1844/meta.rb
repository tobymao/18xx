# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1844
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_DESIGNER = 'Helmut Ohley'
        GAME_LOCATION = 'Switzerland'
        GAME_PUBLISHER = :lookout
        GAME_RULES_URL = 'https://lookout-spiele.de/upload/en_1844_1854.html_Rules_1844_EN.pdf'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1844'

        PLAYER_RANGE = [3, 7].freeze
      end
    end
  end
end
