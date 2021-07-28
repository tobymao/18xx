# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1850
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'Bill Dixon'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1850'
        GAME_LOCATION = 'Mississippi, USA'
        GAME_RULES_URL = 'http://www.hexagonia.com/rules/MFG_1870.pdf'

        PLAYER_RANGE = [2, 6].freeze
      end
    end
  end
end
