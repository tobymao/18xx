# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module GFrost1831
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_TITLE = 'Frost 1831'.freeze
        GAME_ISSUE_LABEL = 'frost1831'
        FIXTURE_DIR_NAME = 'frost1831'

        GAME_DESIGNER = 'Alexandre Madu'.freeze
        GAME_IMPLEMENTER = 'Lucas Leite'.freeze

        GAME_INFO_URL = nil
        GAME_LOCATION = 'New London'.freeze
        GAME_PUBLISHER = nil
        GAME_RULES_URL = nil
        GAME_ALIASES = ['1831'].freeze

        PLAYER_RANGE = [2, 5].freeze

        OPTIONAL_RULES = [].freeze
      end
    end
  end
end
