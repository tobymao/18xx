# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1871
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_TITLE = 'The Old Prince'.freeze
        GAME_SUBTITLE = '1871'.freeze
        GAME_FULL_TITLE = 'The Old Prince: 1871'.freeze
        GAME_DROPDOWN_TITLE = 'The Old Prince: 1871'.freeze

        GAME_DESIGNER = 'Lucas Boyd'.freeze
        GAME_IMPLEMENTER = 'Christopher Giroir'.freeze

        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/TheOldPrince'.freeze
        GAME_LOCATION = 'Prince Edward Island'.freeze
        GAME_PUBLISHER = nil
        GAME_RULES_URL = nil
        GAME_ALIASES = ['1871'].freeze

        PLAYER_RANGE = [3, 4].freeze
      end
    end
  end
end
