# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1868WY
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        PROTOTYPE = true

        GAME_DESIGNER = 'John Harres'
        # GAME_INFO_URL = ''
        # GAME_PUBLISHER = ''
        # GAME_RULES_URL = ''
        GAME_LOCATION = 'Wyoming, USA'
        GAME_TITLE = '1868 Wyoming'
        GAME_FULL_TITLE = '1868: Boom and Bust in the Coal Mines and Oil Fields of Wyoming'

        PLAYER_RANGE = [3, 5].freeze

        OPTIONAL_RULES = [
          {
            sym: :p2_p6_choice,
            short_name: 'P2-P6 choice',
            desc: 'The winners of the privates P2 through P6 in the auction choose to take one of '\
                  'the three corresponding private companies, rather than those being randomly '\
                  'chosen during setup.',
          },
        ].freeze
      end
    end
  end
end
