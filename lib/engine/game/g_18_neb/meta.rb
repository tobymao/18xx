# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18Neb
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'Matthew Campbell'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18Neb'
        GAME_LOCATION = 'Nebraska, USA'
        GAME_PUBLISHER = :deepthoughtgames
        GAME_RULES_URL = 'https://www.scribd.com/document/58813972/18Neb-Rules'

        PLAYER_RANGE = [2, 4].freeze
      end
    end
  end
end
