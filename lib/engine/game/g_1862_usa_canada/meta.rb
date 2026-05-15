# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1862UsaCanada
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_TITLE = '1862 USA Canada'
        GAME_SUBTITLE = 'The First Transcontinental Railroad'
        GAME_DESIGNER = 'Helmut Ohley'
        GAME_LOCATION = 'North America'
        GAME_PUBLISHER = nil
        GAME_RULES_URL = nil
        GAME_INFO_URL = nil

        PLAYER_RANGE = [3, 7].freeze
        OPTIONAL_RULES = [].freeze

        # fs_name must match the actual directory so asset bundling resolves correctly
        def self.fs_name
          'g_1862_usa_canada'
        end
      end
    end
  end
end
