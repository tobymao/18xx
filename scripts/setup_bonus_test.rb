# frozen_string_literal: true

# Setup script: 1862 USA & Canada — ChooseBonus browser test
#
# Creates a 3-player game and drives it to the point where NYC is in its OR
# turn with a 2-train and track connecting F28→F26→F24→F22→F20 (Chicago).
# The user then draws the route in the browser to trigger the ChooseBonus prompt.
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

# Process one action hash through the engine and persist it.
def act!(game_db, action_h)
  actions = game_db.actions(reload: true).map(&:to_h)
  engine  = Engine::Game.load(game_db, actions: actions)
  engine.process_action(action_h, validate_auto_actions: true)
  raise "Engine error: #{engine.exception}" if engine.exception

  raw = engine.raw_actions.last&.to_h
  return unless raw

  next_id = (game_db.actions(reload: true).map(&:action_id).max || 0) + 1
  Action.create(
    game_id:   game_db.id,
    user_id:   game_db.user_id,
    action_id: next_id,
    action:    raw.merge('id' => next_id),
  )
  engine
end

# Convenience: build a pass action. Detects corp vs player by string type.
def pass_h(entity_id)
  type = entity_id.is_a?(String) ? 'corporation' : 'player'
  { 'type' => 'pass', 'entity' => entity_id, 'entity_type' => type }
end

# Buy the first available IPO share of a corporation for a player.
def buy_ipo_share(game_db, player_id, corp_id)
  e    = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
  corp = e.corporation_by_id(corp_id)
  share = corp.ipo_shares.first
  raise "No IPO shares left for #{corp_id}" unless share

  act!(game_db, {
    'type'        => 'buy_shares',
    'entity'      => player_id,
    'entity_type' => 'player',
    'shares'      => [share.id],
  })
end

# Try all 6 rotations for a tile on a hex; return rotation that succeeds or nil.
def find_rotation(game_db, corp_id, hex_id, tile_name)
  6.times do |rot|
    actions = game_db.actions(reload: true).map(&:to_h)
    engine  = Engine::Game.load(game_db, actions: actions)
    hex     = engine.hex_by_id(hex_id)
    tile    = engine.tiles.find { |t| t.name == tile_name && !t.hex }
    next unless tile && hex

    action_h = {
      'type'        => 'lay_tile',
      'entity'      => corp_id,
      'entity_type' => 'corporation',
      'hex'         => hex_id,
      'tile'        => tile.id,
      'rotation'    => rot,
    }
    engine.process_action(action_h)
    return [rot, tile.id] unless engine.exception
  rescue StandardError
    next
  end
  nil
end

# ── create players ────────────────────────────────────────────────────────────
martin = User[1] # neutronc — must exist
alice  = find_or_create_user('Alice', 'alice@1862test.local')
bob    = find_or_create_user('Bob',   'bob@1862test.local')
players = [martin, alice, bob]
puts "Players: #{players.map { |u| "#{u.name}(#{u.id})" }.join(', ')}"

# ── create game ───────────────────────────────────────────────────────────────
game_db = Game.create(
  user_id:     martin.id,
  title:       '1862 USA & Canada',
  description: '',
  min_players: 3,
  max_players: 3,
  settings: {
    seed:         42,
    player_order: players.map(&:id),
    auto_routing: false,
  },
  status: 'new',
  round:  'Unstarted',
)
players.each { |u| GameUser.create(game: game_db, user: u) }
puts "Created game ##{game_db.id}"

# Peek at initial engine to get entity IDs
engine = Engine::Game.load(game_db, actions: [])
p1 = engine.players[0].id   # martin (neutronc)
p2 = engine.players[1].id   # alice
p3 = engine.players[2].id   # bob
puts "Engine player IDs: #{[p1, p2, p3].inspect}"

# ── auction round ─────────────────────────────────────────────────────────────
puts "\n=== Auction Round ==="
companies = engine.companies.sort_by(&:min_bid)
player_cycle = [p1, p2, p3].cycle
companies.each do |c|
  pid = player_cycle.next
  act!(game_db, {
    'type'        => 'bid',
    'entity'      => pid,
    'entity_type' => 'player',
    'company'     => c.sym,
    'price'       => c.min_bid,
  })
  puts "  #{pid} buys #{c.sym} for #{c.min_bid}"
end

# ── Alice forced to par NYH at $100 (NHSC — 8th private → p2) ────────────────
puts "\n=== CompanyPendingPar: par NYH at 100 ==="
act!(game_db, {
  'type'        => 'par',
  'entity'      => p2,
  'entity_type' => 'player',
  'corporation' => 'NYH',
  'share_price' => '100,0,4',
})
puts "  NYH parred at 100"

# ── stock round ───────────────────────────────────────────────────────────────
puts "\n=== Stock Round ==="
# Budget analysis:
#   p3 (Bob)  = $750 - GHU($75) - FNY($180) = $495 available
#   NYC at $70 par: director cert 30%=$210 + 3×10%=3×$70=$210 = $420 total → fits in $495 ✓
#   NYC floats at 60% (30%+30%); bank pays NYC full IPO proceeds = $420 corp cash
#   2-train costs $100 → buyable from $420 corp treasury ✓
# State machine: p3 (Bob) pars NYC at $70, buys 3×10%; everyone else passes.
nyc_director = p3  # Bob(3)
nyc_par_id   = '70,5,4'
nyc_bought   = 0

40.times do
  e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
  break if e.round.is_a?(Engine::Round::Operating)
  break unless e.round.is_a?(Engine::Round::Stock)

  cid  = e.current_entity.id
  name = e.current_entity.name
  nyc  = e.corporation_by_id('NYC')

  if cid == nyc_director
    if nyc.par_price.nil?
      act!(game_db, { 'type' => 'par', 'entity' => cid, 'entity_type' => 'player',
                      'corporation' => 'NYC', 'share_price' => nyc_par_id })
      puts "  #{name} pars NYC at 70"
    elsif nyc_bought < 3
      share = nyc.ipo_shares.first
      act!(game_db, { 'type' => 'buy_shares', 'entity' => cid, 'entity_type' => 'player',
                      'shares' => [share.id] })
      nyc_bought += 1
      puts "  #{name} buys NYC 10% (#{nyc_bought}/3)"
    else
      act!(game_db, pass_h(cid))
    end
  else
    act!(game_db, pass_h(cid))
  end
end
puts "  → Entered OR"

# ── operating rounds ──────────────────────────────────────────────────────────
# Phase 2 has 1 OR per SR, so the flow is SR1→OR1→SR2→OR2→SR3→OR3→SR4→OR4.
# NYC lays: F26 (OR1), F24 (OR2), F22 (OR3), then buys a 2-train in OR4.

def skip_corp_turn(game_db)
  15.times do
    e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
    break unless e.round.is_a?(Engine::Round::Operating)
    break if e.active_step.nil?

    entity = e.current_entity
    act!(game_db, pass_h(entity.id.to_s))
  rescue StandardError
    break
  end
end

# Drain a stock round: everyone passes until we exit SR or hit OR.
def drain_sr(game_db)
  50.times do
    e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
    break unless e.round.is_a?(Engine::Round::Stock)
    break if e.active_step.nil?

    act!(game_db, pass_h(e.current_entity.id))
  rescue StandardError
    break
  end
end

tile_plan = [
  ['F26', '9'],   # OR 1 — straight track edge4(F28)↔edge1(F24), $40 hill cost
  ['F24', '9'],   # OR 2
  ['F22', '9'],   # OR 3
]

tile_plan.each_with_index do |(hex_id, tile_name), or_idx|
  puts "\n=== OR #{or_idx + 1} ==="

  # Phase 2: 1 OR/SR, so there's a stock round before each OR except the first.
  drain_sr(game_db)

  # Skip non-NYC corp turns until NYC comes up
  10.times do
    e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
    break if e.current_entity&.name == 'NYC'
    break unless e.round.is_a?(Engine::Round::Operating)

    skip_corp_turn(game_db)
  end

  # Find valid rotation for the tile
  rot, tile_id = find_rotation(game_db, 'NYC', hex_id, tile_name)
  if rot
    act!(game_db, {
      'type'        => 'lay_tile',
      'entity'      => 'NYC',
      'entity_type' => 'corporation',
      'hex'         => hex_id,
      'tile'        => tile_id,
      'rotation'    => rot,
    })
    puts "  NYC lays #{tile_name}(#{tile_id}) at #{hex_id} rotation #{rot}"
  else
    puts "  WARNING: could not lay #{tile_name} at #{hex_id}, trying alternate tile..."
    %w[7 8 9].each do |alt|
      r, alt_tile_id = find_rotation(game_db, 'NYC', hex_id, alt)
      if r
        act!(game_db, {
          'type' => 'lay_tile', 'entity' => 'NYC', 'entity_type' => 'corporation',
          'hex' => hex_id, 'tile' => alt_tile_id, 'rotation' => r,
        })
        puts "  NYC lays #{alt}(#{alt_tile_id}) at #{hex_id} rotation #{r}"
        break
      end
    end
  end

  # NYC passes remaining steps (route/dividend/train)
  10.times do
    e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
    break if e.current_entity&.name != 'NYC'
    break unless e.round.is_a?(Engine::Round::Operating)

    act!(game_db, pass_h('NYC'))
  rescue StandardError
    break
  end

  # Skip remaining corps
  20.times do
    e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
    break unless e.round.is_a?(Engine::Round::Operating)
    break if e.current_entity&.name == 'NYC'

    skip_corp_turn(game_db)
  end
end

# ── OR 4: NYC buys 2-train, completes turn, then OR 5 stops at Route step ─────
puts "\n=== OR 4 — buy 2-train ==="

drain_sr(game_db)

# Skip to NYC's turn
20.times do
  e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
  break if e.current_entity&.name == 'NYC'
  break unless e.round.is_a?(Engine::Round::Operating)

  skip_corp_turn(game_db)
end

# Pass the track step
e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
if e.active_step.is_a?(Engine::Step::Track)
  act!(game_db, pass_h('NYC'))
  e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
end

# Buy 2-train — NYC has no train yet so BuyTrain accepts after Route auto-passes
if e.active_step.is_a?(Engine::Step::BuyTrain) ||
   e.round.steps.any? { |s| s.is_a?(Engine::Step::BuyTrain) && s.actions(e.current_entity).include?('buy_train') }
  train = e.depot.upcoming.first
  act!(game_db, {
    'type'        => 'buy_train',
    'entity'      => 'NYC',
    'entity_type' => 'corporation',
    'train'       => train.id,
    'price'       => train.price,
  })
  puts "  NYC bought #{train.name}-train"
end

# Pass NYC's remaining steps (BuyTrain → end turn)
10.times do
  e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
  break if e.current_entity&.name != 'NYC'
  break unless e.round.is_a?(Engine::Round::Operating)

  act!(game_db, pass_h('NYC'))
rescue StandardError
  break
end

# Skip remaining OR4 corps
20.times do
  e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
  break unless e.round.is_a?(Engine::Round::Operating)
  break if e.current_entity&.name == 'NYC'

  skip_corp_turn(game_db)
end

# ── OR 5: NYC has 2-train — stop at Route step for browser test ───────────────
puts "\n=== OR 5 — stop at Route step (user draws F28→F20 in browser) ==="

drain_sr(game_db)

# Skip to NYC's turn
20.times do
  e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
  break if e.current_entity&.name == 'NYC'
  break unless e.round.is_a?(Engine::Round::Operating)

  skip_corp_turn(game_db)
end

# Pass NYC's Track step so the user lands directly at Route
e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
if e.current_entity&.name == 'NYC' && e.active_step.is_a?(Engine::Step::Track)
  act!(game_db, pass_h('NYC'))
  puts "  Passed NYC Track step — at Route now"
end

# ── final status ─────────────────────────────────────────────────────────────
game_db.update(status: 'active')
e = Engine::Game.load(game_db, actions: game_db.actions(reload: true).map(&:to_h))
puts "\n#{'=' * 60}"
puts "Game ##{game_db.id} ready!"
puts "URL: http://localhost:9292/game/#{game_db.id}"
puts "State: #{e.round.class.name.split('::').last}, entity=#{e.current_entity&.name}"
puts "Active step: #{e.active_step&.class&.name&.split('::')&.last}"
puts "\nBROWSER TEST:"
puts "  Login as neutronc / password"
puts "  NYC is operating — draw a route from F28 (New York) to F20 (Chicago)"
puts "  ChooseBonus prompt should appear: \$200 cash OR +\$60/OR permanent"
