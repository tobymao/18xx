# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1835
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'Michael Meier-Bachl, Francis Tresham'
        GAME_INFO_URL = 'https://google.com'
        GAME_LOCATION = 'Germany'
        GAME_RULES_URL = 'http://google.com'

        PLAYER_RANGE = [3, 7].freeze
      end
    end
  end
end
