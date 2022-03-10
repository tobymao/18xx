# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1877StockholmTramways
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_TITLE = '1877: Stockholm Tramways'
        GAME_DESIGNER = 'Love Brandefelt'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1877-Stockholm-Tramways'
        GAME_LOCATION = 'Stockholm, Sweden'
        GAME_PUBLISHER = :self_published
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/236903/official-rules'

        PLAYER_RANGE = [3, 6].freeze
      end
    end
  end
end
