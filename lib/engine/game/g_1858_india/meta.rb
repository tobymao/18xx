# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1858India
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha
        PROTOTYPE = true
        DEPENDS_ON = '1858'

        GAME_TITLE = '1858India'
        GAME_DISPLAY_TITLE = '1858 India'
        GAME_FULL_TITLE = '1858: The Railways of India'
        GAME_DESIGNER = 'Ian D Wilson'
        GAME_LOCATION = 'India'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1858-India'
        GAME_RULES_URL = 'https://github.com/tobymao/18xx/wiki/1858-India'
        GAME_IMPLEMENTER = 'Oliver Burnett-Hall'
        GAME_ISSUE_LABEL = '1858India'

        PLAYER_RANGE = [3, 6].freeze

        OPTIONAL_RULES = [
          {
            sym: :quick_start_a,
            short_name: 'Quick start, set A',
            desc: 'The yellow private companies are given to players in ' \
                  'randomly assigned batches, instead of being auctioned.',
            players: (3..6).to_a,
          },
          {
            sym: :quick_start_b,
            short_name: 'Quick start, set B',
            desc: 'Different sets of private companies for five players ' \
                  'in the quick start variant.',
            players: (3..6).to_a,
          },
        ].freeze

        MUTEX_RULES = [%i[quick_start_a quick_start_b]].freeze
      end
    end
  end
end
