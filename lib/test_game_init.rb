# frozen_string_literal: true

# Standalone test: verify that Engine::Game::G18OE::Game initialises without errors.
# Usage: ruby lib/test_game_init.rb   (from the 18xx/ directory)
# Requires: gem install require_all

require 'set'
$LOAD_PATH.unshift File.expand_path('..', __dir__)

require_relative 'engine/debug'
require_relative 'engine/deep_freeze'
require_relative 'engine/jaro_winkler'
require_relative 'engine/logger'

require 'require_all'
require_rel 'engine/game'

begin
  players = [
    { id: 1, name: 'Alice' },
    { id: 2, name: 'Bob' },
    { id: 3, name: 'Carol' },
  ]

  game = Engine::Game::G18OE::Game.new(players)

  puts "[OK] Engine::Game::G18OE::Game initialised successfully"
  puts "  Phase:        #{game.phase.current[:name]}"
  puts "  Corporations: #{game.corporations.map(&:id).join(', ')}"
rescue => e
  puts "[FAIL] #{e.class}: #{e.message}"
  e.backtrace.first(8).each { |l| puts "  #{l}" }
  exit 1
end
