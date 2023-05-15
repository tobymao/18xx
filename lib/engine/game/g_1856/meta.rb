# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1856
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_DESIGNER = 'Bill Dixon'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1856'
        GAME_LOCATION = 'Ontario, Canada'
        GAME_RULES_URL = 'https://www.google.com/search?q=1856+rules'

        GAME_PUBLISHER = :mayfair

        PLAYER_RANGE = [3, 6].freeze
        OPTIONAL_RULES = [
          {
            sym: :alternate_destinations,
            short_name: 'Alternate Destinations',
            desc: 'Use alternate destinations for corporations; see rules for more details',
          },
          {
            sym: :unlimited_bonus_tokens,
            short_name: 'Unlimited +10 bonus tokens',
            desc: 'Unlimited Bridge & Tunnel Tokens (As opposed to normal limit of 3 each)',
          },
          {
            sym: :eight_train_variant,
            short_name: '8-train variant',
            desc: 'Replaces diesel trains with $1000 8-trains (and $350 trade in discount)',
          },
        ].freeze
      end
    end
  end
end
