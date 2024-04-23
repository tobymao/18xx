# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1812
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_SUBTITLE = 'The Cradle Of Steam Railways'
        GAME_DESIGNER = 'Ian D. Wilson'
        GAME_LOCATION = 'North-East England'
        GAME_PUBLISHER = :golden_spike
        GAME_RULES_URL = 'https://drive.google.com/file/d/0B1SWz2pNe2eAZUY2UHNvUFNxUGc/view?usp=sharing&resourcekey=0-D5kk65ZoyT-dR6hSKAmggQ'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1812'

        PLAYER_RANGE = [2, 4].freeze
        OPTIONAL_RULES = [
          {
            sym: :remove_some_minors,
            short_name: 'Remove some minors',
            desc: 'For variety in 2-3 player games, players could agree before the game to randomly choose 2n+2 minor '\
                  'companies (where n is the number of players) and remove the rest from the game.',
          },
        ].freeze
      end
    end
  end
end
