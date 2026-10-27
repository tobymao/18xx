# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18Junta
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        PROTOTYPE = true

        GAME_DESIGNER = 'Leandro Pires'
        GAME_LOCATION = 'Junta (fictional Central America)'
        GAME_RULES_URL = 'https://drive.google.com/file/d/1jOIY8pBolF0xH_4p2UAMrJIrXw9O-pbj/view'

        PLAYER_RANGE = [2, 4].freeze

        OPTIONAL_RULES = [
          {
            sym: :bid_increment_10,
            short_name: 'Faster Private Auction',
            desc: 'Minimum bid increment of $10 (instead of $5) in the private company auction, for a quicker auction. '\
                  'It can be a good fit for asynchronous games.',
          },
        ].freeze
      end
    end
  end
end
