# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1858
      module Meta
        include Game::Meta
        DEV_STAGE = :prealpha

        GAME_TITLE = '1858'
        GAME_SUBTITLE = 'The Railways of Iberia'
        GAME_DESIGNER = 'Ian D Wilson'
        GAME_LOCATION = 'Iberia'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://docs.google.com/viewer?a=v&pid=sites&srcid=YWxsLWFib2FyZGdhbWVzLmNvbXxhYWdsbGN8Z3g6NGJmNDUwZjAyOTYwZDJhMg'

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

        def self.check_options(options, _min_players, _max_players)
          optional_rules = (options || []).map(&:to_sym)
          return if !optional_rules.include?(:quick_start_a) || !optional_rules.include?(:quick_start_b)

          { error: 'Cannot choose both quick start variants.' }
        end
      end
    end
  end
end
