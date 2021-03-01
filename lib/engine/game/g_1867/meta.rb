# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1867
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_DESIGNER = 'Ian D. Wilson'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1867'
        GAME_LOCATION = 'Canada'
        GAME_PUBLISHER = :grand_trunk_games
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/212807/18611867-rulebook'

        PLAYER_RANGE = [3, 6].freeze
      end
    end
  end
end
