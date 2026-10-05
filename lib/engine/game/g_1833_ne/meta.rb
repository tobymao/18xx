# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1833NE
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha # DO NOT GO LIVE BEFORE DECEMBER 1, 2026

        DEPENDS_ON = '1846'
        GAME_DESIGNER = 'Thomas Lehmann'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1833NE'
        GAME_LOCATION = 'Northeastern USA'
        GAME_SUBTITLE = 'Railroading in New England'
        GAME_PUBLISHER = :gmt_games
        GAME_RULES_URL = 'https://gmtwebsiteassets.s3.us-west-2.amazonaws.com/1833NE/1833NE_Rule+book_Web.pdf'

        PLAYER_RANGE = [3, 5].freeze

        OPTIONAL_RULES = [
          {
            sym: :takeover_game,
            short_name: 'Takeover Game',
            desc: ' Adds corporate takeovers and 5 more railroads which can be launched in any open city.',
            players: [3, 4, 5],
          },
        ].freeze
      end
    end
  end
end
