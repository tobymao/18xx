# rip18xx/debug_bridge.rb
require_relative '../../18xx/lib/engine'
require 'json'

puts "=== Compiling 18xx Universal Brain Vector Payload ==="

game_module = Engine::Game.const_get(:G1835)
game_class = game_module.const_get(:Game)

players = ['Stefan', 'Player 2', 'Player 3']
game = game_class.new(players)

game_view_model = {
  current_status: {
    game_id: game.class.name,
    phase: game.phase.current[:name],
    round: game.round.name,
    active_player: game.current_entity.name
  },
  players: game.players.map { |p| { name: p.name, cash: p.cash } },
  companies: game.companies.map { |c| { sym: c.id, name: c.name, value: c.value } },
  hexes: game.hexes.map do |h|
    # Collect vector paths dynamically based on endpoints
    paths = (h.tile.paths || []).map do |p|
      {
        type: 'track',
        a: p.a_num, # Integer for hex side (0-5), nil if internal node
        b: p.b_num, # Integer for hex side (0-5), nil if internal node
        a_type: p.a.class.name.split('::').last.downcase, # 'edge', 'city', 'town', 'offboard'
        b_type: p.b.class.name.split('::').last.downcase,
        gauge: p.track.to_s
      }
    end

    # Track structural city spaces safely without calling undefined properties
    cities = (h.tile.cities || []).map.with_index do |c, idx|
      {
        type: 'city',
        index: idx,
        slots: c.slots,
        value: c.respond_to?(:value) ? c.value : 0
      }
    end

    # Track town/village halts safely
    towns = (h.tile.towns || []).map.with_index do |t, idx|
      {
        type: 'town',
        index: idx,
        value: t.respond_to?(:value) ? t.value : 0
      }
    end

    {
      id: h.id,
      tile_id: h.tile.id,
      color: h.tile.color.to_s,
      rotation: h.tile.rotation,
      vectors: paths + cities + towns
    }
  end
}

File.write('rip18xx/current_game_state.json', JSON.pretty_generate(game_view_model))
puts "Success! Stateless layout vector payload stored in rip18xx/current_game_state.json"