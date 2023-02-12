# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18Texas
      module Meta
        include Game::Meta

        DEV_STAGE = :production
        PROTOTYPE = false

        GAME_LOCATION = 'Texas, United States'
        GAME_DESIGNER = 'Scott Petersen'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18Texas'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://docs.google.com/document/d/1WxUVRZ6uHu32fpaAaRa8z8lXGQLyGqZws3Ce0yDrFNY'

        PLAYER_RANGE = [3, 5].freeze
      end
    end
  end
end
