# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1824
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_SUBTITLE = 'Austrian-Hungarian Railway'
        GAME_DESIGNER = 'Leonhard Orgler & Helmut Ohley'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1824'
        GAME_LOCATION = 'Austria-Hungary'
        GAME_PUBLISHER = :lonny_games
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/188242/1824-english-rules'

        PLAYER_RANGE = [2, 6].freeze
        OPTIONAL_RULES = [
          {
            sym: :cisleithania,
            short_name: 'Cisleithania',
            desc: 'Use the smaller Cislethania map, with some reduction of components - 2-3 players',
          },
          {
            sym: :goods_time,
            short_name: 'Goods Time',
            desc: 'Use the Goods Time Variant (3-6 players) - pre-set scenario',
          },
        ].freeze
      end
    end
  end
end
