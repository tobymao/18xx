# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1824
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha
        DEPENDS_ON = '1837'

        GAME_SUBTITLE = 'Austrian-Hungarian Railway'.freeze
        GAME_DESIGNER = 'Leonhard Orgler & Helmut Ohley'.freeze
        GAME_IMPLEMENTER = 'Per Westling'.freeze
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1824'.freeze
        GAME_LOCATION = 'Austria-Hungary'.freeze
        GAME_PUBLISHER = :lonny_games
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/188242/1824-english-rules'.freeze

        PLAYER_RANGE = [3, 6].freeze
        OPTIONAL_RULES = [
          {
            sym: :goods_time,
            short_name: 'Goods Time',
            desc: 'Use the Goods Time Variant (3-6 players) - pre-set scenario according to the rulebook.',
          },
        ].freeze
        GAME_VARIANTS = [
          {
            sym: :cis,
            name: 'Cisleithania',
            title: '1824 Cisleithania',
            desc: 'Alternate map for 2-3 players',
          },
        ].freeze
      end
    end
  end
end
