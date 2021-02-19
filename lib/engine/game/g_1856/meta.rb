# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1856
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'Bill Dixon'
        GAME_INFO_URL = 'https://google.com'
        GAME_LOCATION = 'Ontario, Canada'
        GAME_RULES_URL = 'http://google.com'

        PLAYER_RANGE = [3, 6].freeze
      end
    end
  end
end
