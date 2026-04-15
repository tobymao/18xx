# frozen_string_literal: true

# Standalone smoke-test: verifies the 18OE game initialises without errors.
# Usage:  ruby lib/test_game_init.rb   (run from 18xx/18xx/)
# Requires: gem install require_all

$LOAD_PATH.unshift File.expand_path('..', __dir__)

require 'require_all'

# Load only what 18OE needs, not the full engine tree (avoids unrelated failures)
require_rel 'engine/config'
require_rel 'engine/part'
require_rel 'engine/tile'
require_rel 'engine/graph'
require_rel 'engine/share'
require_rel 'engine/share_pool'
require_rel 'engine/token'
require_rel 'engine/company'
require_rel 'engine/corporation'
require_rel 'engine/depot'
require_rel 'engine/bank'
require_rel 'engine/player'
require_rel 'engine/phase'
require_rel 'engine/stock_market'
require_rel 'engine/operating_info'
require_rel 'engine/action'
require_rel 'engine/step'
require_rel 'engine/round'
require_rel 'engine/game/base'
require_rel 'engine/game/g_18_oe'

players = [
  { name: 'Alice', id: 1 },
  { name: 'Bob',   id: 2 },
  { name: 'Carol', id: 3 },
]

begin
  game = Engine::Game::G18OE::Game.new(players)
  puts "OK: #{game.class} initialised with #{game.players.size} players"
  puts "    Corporations: #{game.corporations.size}"
  puts "    Companies:    #{game.companies.size}"
  puts "    Phase:        #{game.phase.name}"
  puts "    Round:        #{game.round.class}"
rescue StandardError => e
  puts "FAIL: #{e.class}: #{e.message}"
  puts e.backtrace.first(15).join("\n")
  exit 1
end
