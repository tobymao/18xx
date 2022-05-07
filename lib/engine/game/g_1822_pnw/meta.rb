# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1822PNW
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        DEPENDS_ON = '1822'

        GAME_SUBTITLE = nil
        GAME_DESIGNER = 'Ken Kuhn'.freeze
        GAME_IMPLEMENTER = 'Christopher Giroir'.freeze
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1822PNW'.freeze
        GAME_LOCATION = 'Pacific Northwest'.freeze
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://github.com/tobymao/18xx/wiki/1822PNW'.freeze
        GAME_TITLE = '1822PNW'.freeze

        PLAYER_RANGE = [3, 5].freeze
      end
    end
  end
end
