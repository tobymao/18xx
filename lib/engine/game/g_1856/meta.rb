# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1856
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha

        GAME_DESIGNER = 'Bill Dixon'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1856'
        GAME_LOCATION = 'Ontario, Canada'
        GAME_RULES_URL = 'https://www.google.com/search?q=1856+rules'

        # See: https://www.facebook.com/groups/1824321454265528/permalink/4157468544284129
        GAME_PUBLISHER = :sea_horse

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
        ].freeze
      end
    end
  end
end
