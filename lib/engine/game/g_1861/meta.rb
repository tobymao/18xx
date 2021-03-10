# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1861
      module Meta
        include Game::Meta

        DEV_STAGE = :production
        DEPENDS_ON = '1867'

        GAME_DESIGNER = 'Ian D. Wilson'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1867'
        GAME_LOCATION = 'Russia'
        GAME_PUBLISHER = :grand_trunk_games
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/212807/18611867-rulebook'
        GAME_TITLE = '1861'

        PLAYER_RANGE = [3, 6].freeze
      end
    end
  end
end
