# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1850
      module Meta
        include Game::Meta

        DEV_STAGE = :beta
        DEPENDS_ON = '1870'
        GAME_TITLE = '1850'
        GAME_SUBTITLE = 'The MidWest'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1850'
        GAME_DESIGNER = 'Bill Dixon'
        GAME_LOCATION = 'The Midwestern USA'
        PUBLISHER = :golden_spike
        GAME_RULES_URL = 'https://www.tckroleplaying.com/bg/1850/1850-Rules.pdf'

        OPTIONAL_RULES = [
          {
            sym: :reduced_tokens,
            short_name: 'Reduced Tokens',
            desc: 'CBQ and RI each have one fewer token. All corporations now have 3 station tokens.',
          },
        ].freeze

        PLAYER_RANGE = [2, 6].freeze
      end
    end
  end
end
