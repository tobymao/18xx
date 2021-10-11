# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18TN
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_SUBTITLE = 'The Railroads Come to Tennessee'
        GAME_DESIGNER = 'Mark Derrick'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18TN'
        GAME_LOCATION = 'Tennessee, USA'
        GAME_PUBLISHER = :golden_spike
        GAME_RULES_URL = 'https://drive.google.com/file/d/1r0qnCWW-Qf9ETyXV_jIfHcnn9O5cJcmC/view?usp=sharing'

        PLAYER_RANGE = [3, 5].freeze
      end
    end
  end
end
