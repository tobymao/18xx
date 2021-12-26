# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1832
      module Meta
        include Game::Meta

        DEPENDS_ON = '1870'

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'Bill Dixon'
        GAME_INFO_URL = 'https://google.com'
        GAME_LOCATION = 'Southern States, USA'

        GAME_RULES_URL = 'http://google.com'

        PLAYER_RANGE = [3, 7].freeze
        OPTIONAL_RULES = [].freeze
      end
    end
  end
end
