# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1858
      module Meta
        include Game::Meta
        DEV_STAGE = :production

        GAME_TITLE = '1858'
        GAME_SUBTITLE = 'The Railways of Iberia'
        GAME_DESIGNER = 'Ian D Wilson'
        GAME_LOCATION = 'Iberia'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/266344/1858-rules-v10'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1858'
        GAME_IMPLEMENTER = 'Oliver Burnett-Hall'

        PLAYER_RANGE = [2, 6].freeze

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
            desc: 'Different sets of private companies for four players ' \
                  'in the quick start variant.',
            players: (3..6).to_a,
          },
        ].freeze

        MUTEX_RULES = [%i[quick_start_a quick_start_b]].freeze
      end
    end
  end
end
