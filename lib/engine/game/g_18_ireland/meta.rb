# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18Ireland
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_DESIGNER = 'Ian Scrivins'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18Ireland'
        GAME_LOCATION = 'Ireland'
        GAME_RULES_URL = 'https://www.dropbox.com/s/0rrgo8i5nrs8mts/18Ireland%20Rules%20R2.pdf?dl=0'
        GAME_TITLE = '18Ireland'

        PLAYER_RANGE = [3, 6].freeze
      end
    end
  end
end
