# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1871
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha
        PROTOTYPE = true

        GAME_TITLE = 'The Old Prince 1871'.freeze
        GAME_SUBTITLE = nil
        GAME_FULL_TITLE = 'The Old Prince 1871'.freeze
        GAME_DROPDOWN_TITLE = 'The Old Prince 1871'.freeze
        GAME_ISSUE_LABEL = '1871'

        GAME_DESIGNER = 'Lucas Boyd'.freeze
        GAME_IMPLEMENTER = 'Christopher Giroir'.freeze

        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/TheOldPrince'.freeze
        GAME_LOCATION = 'Prince Edward Island'.freeze
        GAME_PUBLISHER = nil
        GAME_RULES_URL = 'https://s3.amazonaws.com/public.valefor.com/TOP71_RULES_PROTOTYPE.pdf'
        GAME_ALIASES = ['1871'].freeze

        PLAYER_RANGE = [3, 4].freeze
      end
    end
  end
end
