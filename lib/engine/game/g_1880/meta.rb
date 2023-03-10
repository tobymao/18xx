# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1880
      module Meta
        include Game::Meta

        DEV_STAGE = :beta

        GAME_SUBTITLE = 'China'
        GAME_DESIGNER = 'Helmut Ohley, Leonhard Orgler'
        GAME_LOCATION = 'China'
        GAME_PUBLISHER = :lookout
        GAME_RULES_URL = 'https://lookout-spiele.de/upload/en_1880china.html_1880_Regeln_115_EN_WEB.pdf'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1880'

        PLAYER_RANGE = [3, 7].freeze
      end
    end
  end
end
