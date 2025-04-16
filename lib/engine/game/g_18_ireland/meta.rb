# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18Ireland
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_DESIGNER = 'Ian Scrivins'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18Ireland'
        GAME_LOCATION = 'Ireland'
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/219076/18ireland-rules-mass-production-version'
        GAME_TITLE = '18Ireland'

        PLAYER_RANGE = [3, 6].freeze

        OPTIONAL_RULES = [
          {
            sym: :larger_bank,
            short_name: 'Larger £5,000 bank',
            desc: 'Larger bank variant, instead of £4,000',
          },
        ].freeze
      end
    end
  end
end
