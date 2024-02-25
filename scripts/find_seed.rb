# frozen_string_literal: true

require_relative 'scripts_helper'

# find a useful seed by creating games with increasing seed values until the
# given block returns true
#
# title - string
# player_names - Array of strings passed as `names` arg to game class
# log_every - log the number of tried seeds seed periodically; pass 0 to never log
# kwargs - passed to game class; if an id is given it will be used instead of 0
#          for the first game
# block - takes a Game instance, returns true if the desired conditions are met;
#         once this happens, find_seed returns the seed that met the conditions
def find_seed(title, player_names, log_every: 50, **kwargs)
  game_class = Engine.game_by_title(title)
  attempted = 0
  seed = kwargs.delete(:seed) || 0
  loop do
    puts "Checked #{attempted} seeds..." if !log_every.zero? && (seed % log_every).zero? && !seed.zero?
    game = game_class.new(player_names, seed: seed, **kwargs)
    break if yield(game)

    attempted += 1
    seed += 1
  end
  seed
end

def example
  companies = %w[P1 P2].sort

  find_seed('1822', %w[a b c d]) do |game|
    game.bank_companies('P').slice(0, 2).map(&:id).sort == companies
  end
end
