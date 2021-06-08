# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1862
      module Meta
        include Game::Meta

        DEV_STAGE = :beta

        GAME_SUBTITLE = 'Railway Mania in the Eastern Counties'
        GAME_DESIGNER = 'Mike Hutton'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1862'
        GAME_LOCATION = 'Eastern Counties, England'
        GAME_PUBLISHER = :gmt_games
        GAME_RULES_URL = 'https://gmtwebsiteassets.s3-us-west-2.amazonaws.com/1862/1862_TRAIN_RULES-Final.pdf'

        PLAYER_RANGE = [2, 8].freeze
      end
    end
  end
end
