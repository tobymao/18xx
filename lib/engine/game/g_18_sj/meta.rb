# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18SJ
      module Meta
        include Game::Meta

        DEV_STAGE = :production
        PROTOTYPE = true

        GAME_SUBTITLE = 'Railways in the Frozen North (version 0.92)'
        GAME_DESIGNER = 'Örjan Wennman'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18SJ'
        GAME_LOCATION = 'Sweden'
        GAME_PUBLISHER = :self_published
        GAME_RULES_URL = 'https://drive.google.com/file/d/1xALoL0n92l187h01aE176wMdFod090Fy/view'

        PLAYER_RANGE = [2, 6].freeze
        OPTIONAL_RULES = [
          {
            sym: :oscarian_era,
            short_name: 'The Oscarian Era',
            desc: 'Full cap only, sell even if not floated',
          },
          {
            sym: :two_player_variant,
            short_name: 'A.W. Edelswärds 2 Player Variant',
            desc: 'A.W. Edelswärd "bot" plays the 3rd player',
            players: [2],
          },
        ].freeze
      end
    end
  end
end
