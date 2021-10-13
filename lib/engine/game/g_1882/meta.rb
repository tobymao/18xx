# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1882
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_SUBTITLE = 'Assiniboia'
        GAME_DESIGNER = 'Marc Voyer'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1882'
        GAME_LOCATION = 'Assiniboia, Canada'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/206629/1882-rules'

        PLAYER_RANGE = [2, 6].freeze
      end
    end
  end
end
