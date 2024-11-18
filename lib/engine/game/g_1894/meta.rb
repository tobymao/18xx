# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1894
      module Meta
        include Game::Meta

        DEV_STAGE = :beta
        PROTOTYPE = true

        GAME_DESIGNER = 'Jan Kłos'
        GAME_IMPLEMENTER = 'Jan Kłos'
        GAME_TITLE = '1894'
        GAME_LOCATION = 'France and Belgium'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1894'
        GAME_RULES_URL = 'https://github.com/Galatolol/1894/blob/master/1894_rules.pdf'

        PLAYER_RANGE = [3, 4].freeze
      end
    end
  end
end
