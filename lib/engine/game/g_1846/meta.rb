# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1846
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_DESIGNER = 'Thomas Lehmann'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1846'
        GAME_LOCATION = 'Midwest, USA'
        GAME_PUBLISHER = %i[gmt_games golden_spike].freeze
        GAME_RULES_URL = 'https://s3-us-west-2.amazonaws.com/gmtwebsiteassets/1846/1846-RULES-GMT.pdf'
        GAME_SUBTITLE = 'The Race for the Midwest'

        PLAYER_RANGE = [3, 5].freeze
      end
    end
  end
end
