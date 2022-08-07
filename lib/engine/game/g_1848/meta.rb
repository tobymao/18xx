# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1848
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'Leonhard Orgler and Helmut Ohley'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1848'
        GAME_LOCATION = 'Australia'
        GAME_PUBLISHER = %i[gmt_games oo_games].freeze
        GAME_RULES_URL = 'https://gmtwebsiteassets.s3-us-west-2.amazonaws.com/1848/1848-RULES-11a.pdf'

        PLAYER_RANGE = [3, 6].freeze
      end
    end
  end
end
