# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1840
      module Meta
        include Game::Meta

        GAME_SUBTITLE = 'Vienna Tramways'
        GAME_DESIGNER = 'Leonhard Orgler'
        GAME_LOCATION = 'Vienna - Austria'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1840'
        GAME_PUBLISHER = :lonny_games
        GAME_RULES_URL = 'https://www.lonny.at/app/download/10197449884/Rules_ENG_final-compr.pdf'

        PLAYER_RANGE = [2, 6].freeze

        DEV_STAGE = :beta

        OPTIONAL_RULES = [
          {
            sym: :three_player_small,
            short_name: '3P small map',
            desc: 'Use the smaller recommended map for three player',
            players: [3],
          },
        ].freeze
      end
    end
  end
end
