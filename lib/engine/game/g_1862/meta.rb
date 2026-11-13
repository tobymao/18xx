# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1862
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_SUBTITLE = 'Railway Mania in the Eastern Counties'
        GAME_DESIGNER = 'Mike Hutton'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1862'
        GAME_LOCATION = 'Eastern Counties, England'
        GAME_PUBLISHER = :gmt_games
        GAME_RULES_URL = 'https://gmtwebsiteassets.s3-us-west-2.amazonaws.com/1862/1862_TRAIN_RULES-Final.pdf'

        PLAYER_RANGE = [2, 8].freeze
        OPTIONAL_RULES = [
          {
            sym: :eight_tokens,
            short_name: '8 tokens',
            desc: 'Allow a maximum of 8 station markers per company instead of 7',
          },
          {
            sym: :short_length,
            short_name: 'Short Length',
            desc: 'Use reduced train numbers in train roster',
          },
          {
            sym: :long_length,
            short_name: 'Long Length',
            desc: 'Use increased train numbers in train roster',
          },
          {
            sym: :simple_express,
            short_name: 'Simple Express',
            desc: 'Express trains only, recommended for new 18xx players',
          },
          {
            sym: :simple_freight,
            short_name: 'Simple Freight',
            desc: 'Freight trains only, recommended for new 1862 players',
          },
          {
            sym: :advanced_express,
            short_name: 'Advanced Express',
            desc: 'Express and local trains only',
          },
          {
            sym: :advanced_freight,
            short_name: 'Advanced Freight',
            desc: 'Freight and local trains only',
          },
        ].freeze

        GAME_VARIANTS = [
          {
            sym: :solo,
            name: 'Solo',
            title: '1862 Solo',
            desc: 'Solo variant',
          },
        ].freeze

        MUTEX_RULES =
          [
            %i[simple_express simple_freight advanced_express advanced_freight],
            %i[short_length long_length],
          ].freeze
      end
    end
  end
end
