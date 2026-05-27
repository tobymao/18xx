# frozen_string_literal: true

# Setup script: 1862 USA & Canada — ChooseBonus browser test
#
# Creates a 3-player game and drives it to the point where NYC is in its OR
# turn with a 2E-train and track connecting:
#   F28 (NYC home) → F26 → F24 → F22 → G21 → G19 (St. Louis, town) → F20 (Chicago)
#
# Train: 2E (express — pays 2 nodes, visits unlimited).
#   Paying nodes: F28 (city $70) + F20 (city $20) = $90 revenue.
#   G19 (town $0) is visited but pays nothing.
#   Both home hex F28 and bonus hex F20 are in the route → ChooseBonus triggers.
#
# Edge numbering: 0=SW, 1=W, 2=NW, 3=NE, 4=E, 5=SE  (even-column hexes, row F)
# Tile plan:
#   F26 — tile 9 rot 1  (W edge 1 ↔ E edge 4, hill $40)
#   F24 — tile 9 rot 1  (W edge 1 ↔ E edge 4, free)
#   F22 — tile 8 rot 4  (SW edge 0 ↔ E edge 4, medium curve, free)
#   G21 — tile 8 rot 1  (W edge 1 ↔ NE edge 3, medium curve, free)
#   G19 — tile 3 rot 3  (NE edge 3 ↔ E edge 4, sharp town curve, river $40)
#
# Run inside the container:
#   docker compose exec rack ruby scripts/setup_bonus_test.rb

$LOAD_PATH.unshift(File.expand_path('..', __dir__))
require_relative '../models'
%w[user game game_user action session].each { |m| require_relative "../models/#{m}" }
require_relative '../lib/engine'

# ── helpers ──────────────────────────────────────────────────────────────────

def find_or_create_user(name, email)
  User.first(name: name) || begin
    u = User.new
    u.name     = name
    u.email    = email
    u.password = 'password'
    u.settings = {}
    u.save
    u
  end
rescue StandardError => e
  puts "  User create failed (#{e.message}), finding existing..."
  User.first(name: name)
end

def act!(game_db, action_h)
  actions = game_db.actions(reload: true).map(&:to_h)
  engine  = Engine::Game.load(game_db, actions: actions)
  engine.process_action(action_h, validate_auto_actions: true)
  raise "Engine error: #{engine.exception}" if engine.exception

  raw = engine.raw_actions.last&.to_h
  return unless raw

  next_id = (game_db.actions(reload: true).map(&:action_id).max || 0) + 1
  Action.create(
    game_id: game_db.id,
    user_id: game_db.user_id,
    action_id: next_id,
    action: raw.merge('id' => next_id),
  )
  engine
end

def pass_h(entity_id)
  type = entity_id.is_a?(String) ? 'corporation' : 'player'
  { 'type' => 'pass', 'entity' => entity_id, 'entity_type' => type }
end

# Try each tile name × each rotation; return [rot, tile_id, tile_name] on first success.
def find_rotation(game_db, corp_id, hex_id, *tile_names)
  tile_names.each do |tile_name|
    6.times do |rot|
      actions = game_db.actions(reload: true).map(&:to_h)
      engine  = Engine::Game.load(game_db, actions: actions)
      hex     = engine.hex_by_id(hex_id)
      tile    = engine.tiles.find { |t| t.name == tile_name && !t.hex }
      next if tile.nil? || hex.nil?

      action_h = {
        'type' => 'lay_tile',
        'entity' => corp_id,
        'entity_type' => 'corporation',
        'hex' => hex_id,
        'tile' => tile.id,
        'rotation' => rot,
      }
      engine.process_action(action_h)
      return [rot, tile.id, tile_name] unless engine.exception
    rescue StandardError
      next
    end
  end
  nil
end

def skip_corp_turn(game_db)
  15.times do
    e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
    break unless e.round.is_a?(Engine::Round::Operating)
    break if e.active_step.nil?

    act!(game_db, pass_h(e.current_entity.id.to_s))
  rescue StandardError
    break
  end
end

def drain_sr(game_db)
  80.times do
    e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
    break unless e.round.is_a?(Engine::Round::Stock)
    break if e.active_step.nil?

    act!(game_db, pass_h(e.current_entity.id))
  rescue StandardError
    break
  end
end

# ── players ───────────────────────────────────────────────────────────────────
martin = User[1]
alice  = find_or_create_user('Alice', 'alice@1862test.local')
bob    = find_or_create_user('Bob',   'bob@1862test.local')
players = [martin, alice, bob]
puts "Players: #{players.map { |u| "#{u.name}(#{u.id})" }.join(', ')}"

# ── create game ───────────────────────────────────────────────────────────────
game_db = Game.create(
  user_id: martin.id,
  title: '1862 USA & Canada',
  description: '',
  min_players: 3,
  max_players: 3,
  settings: {
    seed: 42,
    player_order: players.map(&:id),
    auto_routing: false,
  },
  status: 'new',
  round: 'Unstarted',
)
players.each { |u| GameUser.create(game: game_db, user: u) }
puts "Created game ##{game_db.id}"

engine = Engine::Game.load(game_db, actions: [])
p1 = engine.players[0].id
p2 = engine.players[1].id
p3 = engine.players[2].id
puts "Player IDs: #{[p1, p2, p3].inspect}"

# ── auction round ─────────────────────────────────────────────────────────────
puts "\n=== Auction ==="
companies = engine.companies.sort_by(&:min_bid)
cycle = [p1, p2, p3].cycle
companies.each do |c|
  pid = cycle.next
  act!(game_db, {
         'type' => 'bid',
         'entity' => pid,
         'entity_type' => 'player',
         'company' => c.sym,
         'price' => c.min_bid,
       })
  puts "  #{pid} buys #{c.sym} for #{c.min_bid}"
end

# ── CompanyPendingPar: NHSC forces NYH par ────────────────────────────────────
puts "\n=== CompanyPendingPar: NYH par at 100 ==="
act!(game_db, {
       'type' => 'par',
       'entity' => p2,
       'entity_type' => 'player',
       'corporation' => 'NYH',
       'share_price' => '100,0,4',
     })
puts '  NYH parred at 100'

# ── stock round: Bob pars NYC at $70, buys 3×10% to float ────────────────────
# Full capitalisation: 10 shares × $70 = $700 treasury
# Cost: director 30% ($210) + 3×10% ($210) = $420 out of Bob's ~$495 budget
puts "\n=== SR: par and float NYC at $70 ==="
nyc_bought = 0
60.times do
  e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
  break if e.round.is_a?(Engine::Round::Operating)
  break unless e.round.is_a?(Engine::Round::Stock)

  cid = e.current_entity.id
  nyc = e.corporation_by_id('NYC')

  if cid == p3
    if nyc.par_price.nil?
      act!(game_db, {
             'type' => 'par',
             'entity' => cid,
             'entity_type' => 'player',
             'corporation' => 'NYC',
             'share_price' => '70,5,4',
           })
      puts '  Bob pars NYC at 70'
    elsif nyc_bought < 3
      act!(game_db, {
             'type' => 'buy_shares',
             'entity' => cid,
             'entity_type' => 'player',
             'shares' => [nyc.ipo_shares.first.id],
           })
      nyc_bought += 1
      puts "  Bob buys NYC 10% (#{nyc_bought}/3)"
    else
      act!(game_db, pass_h(cid))
    end
  else
    act!(game_db, pass_h(cid))
  end
end
puts '  → entered OR (NYC treasury: $700)'

# ── tile-laying ORs 1-5 ───────────────────────────────────────────────────────
# One yellow tile per OR (phase 2).  Terrain: F26 hill $40, G19 river $40.
tile_plan = [
  ['F26', %w[9 8]],
  ['F24', %w[9 8]],
  ['F22', %w[8 2]],
  ['G21', %w[8 2]],
  ['G19', %w[3 4 58]],
]

tile_plan.each_with_index do |(hex_id, candidates), or_idx|
  puts "\n=== OR #{or_idx + 1} — lay tile at #{hex_id} ==="
  drain_sr(game_db)

  20.times do
    e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
    break if e.current_entity&.name == 'NYC'
    break unless e.round.is_a?(Engine::Round::Operating)

    skip_corp_turn(game_db)
  end

  result = find_rotation(game_db, 'NYC', hex_id, *candidates)
  raise "ERROR: could not lay tile at #{hex_id} with candidates #{candidates.inspect}" unless result

  rot, tile_id, tile_name = result
  act!(game_db, {
         'type' => 'lay_tile',
         'entity' => 'NYC',
         'entity_type' => 'corporation',
         'hex' => hex_id,
         'tile' => tile_id,
         'rotation' => rot,
       })
  puts "  NYC lays tile #{tile_name}(#{tile_id}) at #{hex_id} rotation #{rot}"

  15.times do
    e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
    break if e.current_entity&.name != 'NYC'
    break unless e.round.is_a?(Engine::Round::Operating)

    act!(game_db, pass_h('NYC'))
  rescue StandardError
    break
  end

  30.times do
    e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
    break unless e.round.is_a?(Engine::Round::Operating)
    break if e.current_entity&.name == 'NYC'

    skip_corp_turn(game_db)
  end
end

# ── OR 6: buy 2E-train ────────────────────────────────────────────────────────
# 2E pays 2 nodes (city/town), visits unlimited. F28+F20 are the paying nodes.
# G19 (town $0) is visited on the path but pays nothing — bonus still triggers.
puts "\n=== OR 6 — buy 2E-train ==="
drain_sr(game_db)

20.times do
  e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
  break if e.current_entity&.name == 'NYC'
  break unless e.round.is_a?(Engine::Round::Operating)

  skip_corp_turn(game_db)
end

e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
act!(game_db, pass_h('NYC')) if e.current_entity&.name == 'NYC' && e.active_step.is_a?(Engine::Step::Track)

e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
train = e.depot.upcoming.find { |t| t.name == '2' }
raise 'No 2-train available in depot!' unless train

act!(game_db, {
       'type' => 'buy_train',
       'entity' => 'NYC',
       'entity_type' => 'corporation',
       'train' => train.id,
       'price' => 150,
       'variant' => '2E',
     })
puts '  NYC bought 2E-train for $150'

15.times do
  e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
  break if e.current_entity&.name != 'NYC'
  break unless e.round.is_a?(Engine::Round::Operating)

  act!(game_db, pass_h('NYC'))
rescue StandardError
  break
end

30.times do
  e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
  break unless e.round.is_a?(Engine::Round::Operating)
  break if e.current_entity&.name == 'NYC'

  skip_corp_turn(game_db)
end

# ── OR 7: stop at Route step ──────────────────────────────────────────────────
# Phase 3 has 2 ORs/SR; OR7 is the first OR after SR7.
puts "\n=== OR 7 — stop at Route step ==="
drain_sr(game_db)

20.times do
  e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
  break if e.current_entity&.name == 'NYC'
  break unless e.round.is_a?(Engine::Round::Operating)

  skip_corp_turn(game_db)
end

e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
if e.current_entity&.name == 'NYC' && e.active_step.is_a?(Engine::Step::Track)
  act!(game_db, pass_h('NYC'))
  puts '  Passed Track step — NYC now at Route'
end

# ── finalize ──────────────────────────────────────────────────────────────────
game_db.update(status: 'active')
e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
nyc = e.corporation_by_id('NYC')
puts "\n#{'=' * 60}"
puts "Game ##{game_db.id} ready!"
puts "URL: http://localhost:9292/game/#{game_db.id}"
puts "State: #{e.round.class.name.split('::').last}, entity=#{e.current_entity&.name}"
puts "Active step: #{e.active_step&.class&.name&.split('::')&.last}"
puts "NYC treasury: $#{nyc.cash}  trains: #{nyc.trains.map(&:name).inspect}"
puts "\nBROWSER TEST:"
puts "  1. Login as neutronc / password, open game ##{game_db.id}"
puts '  2. NYC is operating with a 2E-train — draw a route:'
puts '       F28 (New York) → F26 → F24 → F22 → G21 → G19 (St. Louis) → F20 (Chicago)'
puts '  3. 2E visits all 3 nodes; pays F28($70) + F20($20) = $90 (G19 $0)'
puts "  4. ChooseBonus prompt should appear: \$200 cash OR +\$60/OR permanent"
