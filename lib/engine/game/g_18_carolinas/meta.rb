# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18Carolinas
      module Meta
        include Game::Meta

        DEV_STAGE = :production
        PROTOTYPE = true

        GAME_SUBTITLE = 'Southern Steam to the Piedmont Plateau'
        GAME_DESIGNER = 'Scott Petersen'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18Carolinas'
        GAME_LOCATION = 'North and South Carolina, USA'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://docs.google.com/document/d/1PTgNpwbjqFkKiQXS8rwF0hmuwDyAesnklOubL3QpSKw'

        PLAYER_RANGE = [2, 6].freeze
      end
    end
  end
end
