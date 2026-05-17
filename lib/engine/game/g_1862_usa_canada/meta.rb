# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1862UsaCanada
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DISPLAY_TITLE = '1862 USA Canada 2025 Version'
        GAME_TITLE = '1862UsaCanada'
        GAME_SUBTITLE = 'The First Transcontinental Railroad'
        GAME_DESIGNER = 'Helmut Ohley'
        GAME_LOCATION = 'North America'
        GAME_PUBLISHER = nil
        GAME_RULES_URL = nil
        GAME_INFO_URL = nil

        PLAYER_RANGE = [3, 7].freeze
        OPTIONAL_RULES = [].freeze
      end
    end
  end
end
