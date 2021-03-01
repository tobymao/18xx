# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1822
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha

        GAME_DESIGNER = 'Simon Cutforth'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1822'
        GAME_LOCATION = 'Great Britain'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://docs.google.com/document/d/1yUap9cNais_Tapv6ZjudbvukmKPgRUhY32BOaqcH8Hw/edit'

        PLAYER_RANGE = [3, 7].freeze
      end
    end
  end
end
