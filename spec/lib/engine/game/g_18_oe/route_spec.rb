# frozen_string_literal: true

require 'spec_helper'
require 'json'
require 'timeout'
require_relative 'helpers'

shared_context 'with 18OE route helpers' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:corp) { game.corporation_by_id('A') }
  let(:c1) { game.hex_by_id('J79').tile.cities.first }
  let(:c3) { game.hex_by_id('J83').tile.cities.first }
  let(:c2) { game.hex_by_id('K80').tile.cities.first }

  def buy_train!(name)
    train = game.trains.find { |t| t.name == name && !t.owner.is_a?(Engine::Corporation) }
    game.buy_train(corp, train, :free)
    train
  end

  def route_through(train, *nodes)
    route = Engine::Route.new(game, game.phase, train, routes: [])
    route.routes = [route]
    nodes.each { |node| route.touch_node(node) }
    route
  end

  def explicit_route(train, *nodes)
    route = Engine::Route.new(game, game.phase, train, routes: [])
    route.routes = [route]
    nodes.each_cons(2) do |left, right|
      chain = route.select(left, right).first
      raise "No unused connection between #{left.signature} and #{right.signature}" unless chain

      route.connection_data << route.segment(chain, left: left)
    end
    route
  end

  def lay_code!(hex_id, code)
    game.hex_by_id(hex_id).lay(Engine::Tile.from_code("X#{hex_id}", :green, code))
  end

  def rebuild(route)
    rebuilt = Engine::Route.new(game, game.phase, route.train, routes: [], connection_hexes: route.connection_hexes)
    rebuilt.routes = [rebuilt]
    rebuilt
  end

  def node_sequence(route)
    route.connection_data.map { |c| [c[:left], c[:right]] }
  end
end

describe 'G18OE routes through a town twice (§11.3.1)' do
  include_context 'with 18OE route helpers'

  let(:town_hex) { game.hex_by_id('J81') }
  let(:town) { town_hex.tile.towns.first }
  let(:five) { buy_train!('5') }
  let(:two_plus_two) { buy_train!('2+2') }
  let(:three) { buy_train!('3') }

  before do
    lay_code!('J81', 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0')
    lay_code!('J79', 'city=revenue:20;path=a:4,b:_0')
    lay_code!('J83', 'city=revenue:40;path=a:1,b:_0')
    lay_code!('K80', 'city=revenue:30;path=a:3,b:_0;path=a:4,b:_0')
    lay_code!('K82', 'path=a:1,b:2')
    c1.place_token(corp, corp.next_token, check_tokenable: false)
    game.graph.clear
  end

  it 'runs a train through a town twice, paying it once' do
    route = route_through(five, c1, town, c2, town, c3)

    expect(route.revenue).to eq(100)
  end

  it 'builds the second pass by clicking the town again' do
    route = route_through(five, c1, town, c2, town, c3)

    expect(route.connection_data.size).to eq(4)
    expect(route.visited_stops).to contain_exactly(c1, town, c2, c3)
  end

  it "counts a revisited town once toward the train's distance" do
    route = route_through(three, c1, town, c2, town)

    expect(route.visited_stops).to contain_exactly(c1, town, c2)
    expect(route.revenue).to eq(60)
  end

  it 'trims the route as usual when no unused track reaches the clicked middle town' do
    route = route_through(five, c1, town, c3)
    route.touch_node(town)

    expect(node_sequence(route)).to eq([[town, c1]])
    expect(route.visited_stops).to contain_exactly(town, c1)
  end

  it 'closes a loop by clicking the starting town again, then continues from it' do
    c2.place_token(corp, corp.next_token, check_tokenable: false)
    game.graph.clear
    route = route_through(five, town, c2, town, c3)

    expect(route.connection_data.size).to eq(3)
    expect(route.visited_stops).to contain_exactly(town, c2, c3)
    expect(route.revenue).to eq(80)
  end

  it 'rebuilds a route that closed a loop on its starting town from its saved form' do
    c2.place_token(corp, corp.next_token, check_tokenable: false)
    game.graph.clear
    route = route_through(five, town, c2, town, c3)
    rebuilt = rebuild(route)

    expect(node_sequence(rebuilt)).to eq(node_sequence(route))
    expect(rebuilt.revenue).to eq(80)
  end

  it 'still removes the starting town of a one-segment route when clicked' do
    route = route_through(five, town, c1)
    route.touch_node(town)

    expect(route.connection_data).to be_empty
  end

  it 'trims the route as usual when no unused track leads back to the clicked starting town' do
    c2.place_token(corp, corp.next_token, check_tokenable: false)
    game.graph.clear
    route = route_through(five, town, c2, town, c3)
    route.touch_node(town)

    expect(route.connection_data.size).to eq(2)
    expect(route.visited_stops).to contain_exactly(town, c2, c3)
  end

  it 'alternates between the single pass and the closed loop when its town is clicked again' do
    c2.place_token(corp, corp.next_token, check_tokenable: false)
    game.graph.clear
    route = route_through(five, town, c2, town)

    sequences = Array.new(4) do
      route.touch_node(town)
      node_sequence(route)
    end

    expect(sequences).to eq([[[c2, town]], [[town, c2], [c2, town]], [[c2, town]], [[town, c2], [c2, town]]])
  end

  [[:head, true], [:tail, false]].each do |side, town_first|
    it "adds a return connection when the revisitable town is at the #{side}" do
      nodes = town_first ? [town, c2] : [c2, town]
      route = explicit_route(five, *nodes)
      original = route.connection_data.first
      route.touch_node(town)

      expect(route.connection_data.size).to eq(2)
      expect(route.connection_data).to include(original)
      expect([route.head[:left], route.tail[:right]]).to eq([town, town])
      expect(route.paths.uniq).to eq(route.paths)
    end

    it "does not add a return connection when the town at the #{side} is not revisitable" do
      nodes = town_first ? [town, c2] : [c2, town]
      route = explicit_route(five, *nodes)
      original = route.connection_data.first
      allow(game).to receive(:route_node_revisitable?).and_return(false)
      route.touch_node(town)

      expect(route.connection_data.size).to be < 2
      expect(route.connection_data).not_to include(original)
    end

    it "follows the usual click behavior when no unused track returns to the town at the #{side}" do
      nodes = town_first ? [town, c1] : [c1, town]
      route = explicit_route(five, *nodes)
      route.touch_node(town)

      expect(route.connection_data.size).to be < 2
    end
  end

  it 'asks the game about revisiting an endpoint of another node type' do
    route = explicit_route(five, c2, town)
    allow(game).to receive(:route_node_revisitable?).and_return(false)
    allow(game).to receive(:route_node_revisitable?).with(c2).and_return(true)
    route.touch_node(c2)

    expect(route.connection_data.size).to eq(2)
    expect([route.head[:left], route.tail[:right]]).to eq([c2, c2])
  end

  it 'clears the route through normal cycling when a city that is not revisitable is clicked' do
    route = explicit_route(five, c2, town)
    sizes = Array.new(3) do
      route.touch_node(c2)
      route.connection_data.size
    end

    expect(sizes).to all(be < 2)
    expect(sizes.last).to eq(0)
  end

  it 'does not chain a node to itself' do
    route = route_through(five, town, c2, town)

    expect(route.select(town, town)).to be_empty
  end

  it 'does not close a loop on the starting town when the game does not allow revisiting it' do
    allow(game).to receive(:route_node_revisitable?).and_return(false)
    route = route_through(five, town, c2, town)

    expect(route.connection_data).to be_empty
  end

  it 'rejects a town revisit when the game does not allow it' do
    segments = route_through(five, c1, town, c2, town, c3).connection_data
    allow(game).to receive(:route_node_revisitable?).and_return(false)
    route = Engine::Route.new(game, game.phase, five, routes: [], connection_data: segments)
    route.routes = [route]

    expect { route.revenue }.to raise_error(Engine::ReusesCity)
  end

  it 'rebuilds a route that revisits a town from its saved form' do
    route = route_through(five, c1, town, c2, town, c3)
    rebuilt = rebuild(route)

    expect(node_sequence(rebuilt)).to eq(node_sequence(route))
    expect(rebuilt.revenue).to eq(100)
  end

  it 'rebuilds a route that ends on the revisited town from its saved form' do
    route = route_through(two_plus_two, c1, town, c2, town)
    rebuilt = rebuild(route)

    expect(node_sequence(rebuilt)).to eq(node_sequence(route))
    expect(rebuilt.revenue).to eq(60)
  end

  it 'rebuilds a revisit route through the run routes action' do
    route = route_through(five, c1, town, c2, town, c3)
    action = Engine::Action::RunRoutes.new(corp, routes: [route])
    restored = Engine::Action::RunRoutes.from_h(action.to_h, game)

    expect(node_sequence(restored.routes.first)).to eq(node_sequence(route))
    expect(restored.routes.first.revenue).to eq(100)
  end

  it 'rebuilds a route that starts with a revisit loop, reading the loop from the segments after it' do
    full = route_through(five, c1, town, c2, town, c3)
    rebuilt = Engine::Route.new(game, game.phase, five, routes: [], connection_hexes: full.connection_hexes[1..])
    rebuilt.routes = [rebuilt]

    expect(node_sequence(rebuilt)).to eq([[town, c2], [c2, town], [town, c1]])
    expect(rebuilt.revenue).to eq(60)
  end

  it 'rebuilds a lone revisit loop with the town, not the city, as the repeated stop' do
    full = route_through(five, c1, town, c2, town, c3)
    rebuilt = Engine::Route.new(game, game.phase, five, routes: [], connection_hexes: full.connection_hexes[1..2])
    rebuilt.routes = [rebuilt]

    expect(node_sequence(rebuilt)).to eq([[town, c2], [c2, town]])
  end

  it 'saves each connection with its endpoint nodes and unchanged hex ids' do
    route = route_through(five, c1, town, c2, town, c3)
    saved = route.connection_hexes

    expect(saved.map { |c| [c['from'], c['to']] }).to eq(node_sequence(route).map { |l, r| [l.signature, r.signature] })
    expect(saved.map { |c| c['hexes'] }).to eq(route.connection_data.map { |c| route.send(:chain_id, c[:chain][:paths]) })
    expect(saved.flat_map(&:keys).uniq).to contain_exactly('from', 'hexes', 'to')
  end

  it 'round-trips a saved route through JSON' do
    route = route_through(five, c1, town, c2, town, c3)
    action = Engine::Action::RunRoutes.new(corp, routes: [route])
    restored = Engine::Action::RunRoutes.from_h(JSON.parse(JSON.generate(action.to_h)), game)

    expect(node_sequence(restored.routes.first)).to eq(node_sequence(route))
    expect(restored.routes.first.revenue).to eq(100)
  end

  it 'exposes the flattened hex ids of every connection' do
    route = route_through(five, c1, town, c2, town, c3)

    expect(route.connection_hex_ids).to eq(route.connection_hexes.flat_map { |c| c['hexes'] })
    expect(route.connection_hex_ids).to include('K82')
  end

  it 'reads a legacy save without endpoints by inferring them from adjacency' do
    route = route_through(five, c1, town, c3)
    legacy = Engine::Route.new(game, game.phase, five, routes: [],
                                                       connection_hexes: route.connection_hexes.map { |c| c['hexes'] },
                                                       nodes: route.node_signatures)
    legacy.routes = [legacy]

    expect(legacy.visited_stops).to contain_exactly(c1, town, c3)
    expect(legacy.revenue).to eq(route.revenue)
  end

  it 'reads a legacy save whose hex lists run in mixed directions' do
    route = route_through(five, c1, town, c3)
    hexes = route.connection_hexes.map { |c| c['hexes'] }
    legacy = Engine::Route.new(game, game.phase, five, routes: [], connection_hexes: [hexes[0], hexes[1].reverse])
    legacy.routes = [legacy]

    expect(legacy.visited_stops).to contain_exactly(c1, town, c3)
  end

  it 'reads a legacy single-segment save through the tokened node' do
    route = route_through(five, c1, town)
    hexes = route.connection_hexes.map { |c| c['hexes'] }
    legacy = Engine::Route.new(game, game.phase, five, routes: [], connection_hexes: hexes)
    legacy.routes = [legacy]

    expect(legacy.visited_stops).to contain_exactly(c1, town)
  end

  it 'falls back to inference when a saved endpoint no longer exists' do
    route = route_through(five, c1, town, c3)
    saved = route.connection_hexes.map(&:dup)
    saved[0]['from'] = 'Z99-9'
    rebuilt = Engine::Route.new(game, game.phase, five, routes: [], connection_hexes: saved, nodes: route.node_signatures)
    rebuilt.routes = [rebuilt]

    expect(rebuilt.visited_stops).to contain_exactly(c1, town, c3)
    expect(rebuilt.revenue).to eq(route.revenue)
  end

  it 'falls back to inference when both saved endpoints exist but no chain joins them with the saved hexes' do
    route = route_through(five, c1, town, c3)
    saved = route.connection_hexes.map(&:dup)
    saved[0]['to'] = c2.signature
    rebuilt = Engine::Route.new(game, game.phase, five, routes: [], connection_hexes: saved, nodes: route.node_signatures)
    rebuilt.routes = [rebuilt]

    expect(rebuilt.visited_stops).to contain_exactly(c1, town, c3)
    expect(rebuilt.revenue).to eq(route.revenue)
  end

  context 'when inferring the first segment of a legacy save from hand-built chains' do
    let(:stop) { Struct.new(:signature) }
    let(:left_one) { stop.new('L1') }
    let(:left_two) { stop.new('L2') }
    let(:middle) { stop.new('M') }
    let(:far_one) { stop.new('F1') }
    let(:far_two) { stop.new('F2') }
    let(:shared_path) { Object.new }
    let(:other_path) { Object.new }

    def chain(first, second, *paths)
      { nodes: [first, second], paths: paths, hexes: nil, id: nil }
    end

    def reader(saved_signatures)
      route = Engine::Route.new(game, game.phase, five, routes: [], nodes: saved_signatures)
      route.routes = [route]
      route
    end

    let(:five) { buy_train!('5') }

    it 'discards next-segment chains whose track another route already uses' do
      route = reader(nil)
      allow(route).to receive(:find_matching_chains).and_return([chain(middle, far_one, other_path), chain(middle, far_two)])
      read = route.send(:read_first_connection, [chain(left_one, middle)], ['next'], [other_path])

      expect([read[:left], read[:right], read[:chain]]).to eq([left_one, middle, chain(left_one, middle)])
    end

    it 'finds no first segment when every next-segment chain uses track already taken' do
      route = reader(nil)
      allow(route).to receive(:find_matching_chains).and_return([chain(middle, far_one, other_path)])

      expect(route.send(:read_first_connection, [chain(left_one, middle)], ['next'], [other_path])).to be_nil
    end

    it 'scores the left, middle and far nodes of each pair, keeping the first on a tie' do
      route = reader(%w[L1 M F1])
      first = chain(left_two, middle)
      second = chain(left_one, middle, shared_path)
      allow(route).to receive(:find_matching_chains).and_return([chain(middle, far_one, shared_path), chain(middle, far_two)])
      read = route.send(:read_first_connection, [first, second], ['next'], [])

      expect(read[:left]).to eq(left_two)
    end
  end

  it 'reads a saved loop over two parallel tracks using each track once' do
    c2.place_token(corp, corp.next_token, check_tokenable: false)
    game.graph.clear
    route = route_through(five, town, c2, town)
    rebuilt = rebuild(route)

    expect(node_sequence(rebuilt)).to eq(node_sequence(route))
    expect(rebuilt.paths.uniq.size).to eq(rebuilt.paths.size)
  end
end

describe 'G18OE routes through a double town twice (§11.3.1)' do
  include_context 'with 18OE route helpers'

  let(:double_town) { game.hex_by_id('J81').tile.double_towns.first }

  def route_pair(first_nodes, second_nodes)
    routes = [first_nodes, second_nodes].map { |_| Engine::Route.new(game, game.phase, buy_train!('5'), routes: []) }
    routes.each { |route| route.routes = routes }
    routes.zip([first_nodes, second_nodes]).each { |route, nodes| nodes.each { |node| route.touch_node(node) } }
    routes
  end

  def rebuild_with_stale_node(route)
    Engine::Route.new(game, game.phase, route.train, routes: [], connection_hexes: route.connection_hexes,
                                                     nodes: route.node_signatures + ['missing-node']).tap do |rebuilt|
      rebuilt.routes = [rebuilt]
    end
  end

  let(:j81_code) { 'double_town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0' }
  let(:j79_code) { 'city=revenue:20;path=a:4,b:_0' }

  before do
    lay_code!('J81', j81_code)
    lay_code!('J79', j79_code)
    lay_code!('J83', 'city=revenue:40;path=a:1,b:_0')
    lay_code!('K80', 'city=revenue:30;path=a:3,b:_0;path=a:4,b:_0')
    lay_code!('K82', 'path=a:1,b:2')
    c1.place_token(corp, corp.next_token, check_tokenable: false)
    game.graph.clear
  end

  it 'accepts a train that passes a double town twice, paying each half once' do
    route = explicit_route(buy_train!('5'), c1, double_town, c2, double_town, c3)

    expect(route.revenue).to eq(110)
    expect(route.visited_stops).to contain_exactly(c1, *double_town.stops, c2, c3)
  end

  it 'starts the second pass with one click on the double town' do
    route = route_through(buy_train!('5'), c1, double_town, c2, double_town)

    expect(route.connection_data.size).to eq(3)
    route.touch_node(c3)
    expect(route.visited_stops).to contain_exactly(c1, *double_town.stops, c2, c3)
    expect(route.revenue).to eq(110)
  end

  it 'trims the end city when no unused track reaches the double town for a second pass' do
    route = route_through(buy_train!('5'), c1, double_town, c3)
    route.touch_node(double_town)

    expect(node_sequence(route)).to eq([[double_town, c1]])
  end

  it 'closes a loop on the double town the route starts on, then continues' do
    c2.place_token(corp, corp.next_token, check_tokenable: false)
    game.graph.clear
    route = route_through(buy_train!('5'), double_town, c2, double_town, c3)

    expect(route.connection_data.size).to eq(3)
    expect(route.visited_stops).to contain_exactly(*double_town.stops, c2, c3)
    expect(route.revenue).to eq(90)
  end

  it 'alternates between the single pass and the closed loop on repeated clicks' do
    c2.place_token(corp, corp.next_token, check_tokenable: false)
    game.graph.clear
    route = route_through(buy_train!('5'), double_town, c2, double_town)

    sizes = Array.new(4) do
      route.touch_node(double_town)
      route.connection_data.size
    end

    expect(sizes).to eq([1, 2, 1, 2])
  end

  it 'rebuilds a double-town revisit route from its saved form' do
    route = explicit_route(buy_train!('5'), c1, double_town, c2, double_town, c3)
    rebuilt = rebuild(route)

    expect(node_sequence(rebuilt)).to eq(node_sequence(route))
    expect(rebuilt.connection_hexes).to eq(route.connection_hexes)
    expect(rebuilt.revenue).to eq(110)
  end

  it 'rebuilds a double-town revisit route through the run routes action' do
    route = route_through(buy_train!('5'), c1, double_town, c2, double_town, c3)
    action = Engine::Action::RunRoutes.new(corp, routes: [route])
    restored = Engine::Action::RunRoutes.from_h(action.to_h, game)

    expect(node_sequence(restored.routes.first)).to eq(node_sequence(route))
    expect(restored.routes.first.revenue).to eq(110)
  end

  it 'rejects a double-town revisit when the game does not allow it' do
    segments = explicit_route(buy_train!('5'), c1, double_town, c2, double_town, c3).connection_data
    allow(game).to receive(:route_node_revisitable?).and_return(false)
    route = Engine::Route.new(game, game.phase, buy_train!('3'), routes: [], connection_data: segments)
    route.routes = [route]

    expect { route.revenue }.to raise_error(Engine::ReusesCity)
  end

  it 'lets two trains of one corporation pass the same double town on different exits (§11.3.8)' do
    c3.place_token(corp, corp.next_token, check_tokenable: false)
    game.graph.clear
    first, second = route_pair([c1, double_town, c2], [c3, double_town, c2])

    expect(first.revenue).to eq(70)
    expect(second.revenue).to eq(90)
  end

  it 'keeps the double town the route ends on when the saved nodes include one no longer on the route' do
    c2.place_token(corp, corp.next_token, check_tokenable: false)
    game.graph.clear
    original = explicit_route(buy_train!('5'), c2, double_town)
    rebuilt = rebuild_with_stale_node(original)

    expect(rebuilt.visited_stops).to contain_exactly(*double_town.stops, c2)
    expect(rebuilt.revenue).to eq(50)
  end

  context 'with a second track from the first city into the double town' do
    let(:j81_code) { 'double_town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0' }
    let(:j79_code) { 'city=revenue:20;path=a:3,b:_0;path=a:4,b:_0' }

    before do
      lay_code!('I80', 'path=a:0,b:5')
      game.graph.clear
    end

    it 'takes the second pass from the end that can reach the double town' do
      route = route_through(buy_train!('5'), c2, double_town, c1)
      route.touch_node(double_town)

      expect(route.connection_data.size).to eq(3)
      route.touch_node(c3)

      expect(route.visited_stops).to contain_exactly(c1, *double_town.stops, c2, c3)
      expect(route.revenue).to eq(110)
    end
  end

  context 'with two cities on one track into the double town' do
    let(:j81_code) { 'double_town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0' }
    let(:i80_west) { game.hex_by_id('I80').tile.cities[0] }
    let(:i80_east) { game.hex_by_id('I80').tile.cities[1] }

    before do
      lay_code!('I80', 'city=revenue:50;city=revenue:60;path=a:5,b:_0;path=a:5,b:_1')
      i80_west.place_token(corp, corp.next_token, check_tokenable: false)
      game.graph.clear
    end

    it 'rejects two trains that enter the double town over the same exit, even over different city tracks (§11.3.8)' do
      first = route_through(buy_train!('5'), i80_west, double_town, c3)
      second = route_through(buy_train!('5'), c2, double_town, i80_east)
      [first, second].each { |route| route.routes = [first, second] }

      expect { first.revenue }.to raise_error(Engine::GameError, /J81/)
    end
  end
end

describe 'G18OE revisiting a town deep inside a route (§11.3.1)' do
  include_context 'with 18OE route helpers'

  let(:west) { game.hex_by_id('J77').tile.cities.first }
  let(:middle) { game.hex_by_id('J79').tile.cities.first }
  let(:hub) { game.hex_by_id('K80').tile.cities.first }
  let(:loop_city) { game.hex_by_id('K82').tile.cities.first }
  let(:track) { 'path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0' }
  let(:train) { buy_train!('5') }

  before do
    lay_code!('J81', j81_code)
    lay_code!('J77', 'city=revenue:10;path=a:4,b:_0')
    lay_code!('J79', 'city=revenue:20;path=a:1,b:_0;path=a:4,b:_0')
    lay_code!('K80', 'city=revenue:30;path=a:3,b:_0;path=a:4,b:_0')
    lay_code!('K82', 'city=revenue:40;path=a:1,b:_0;path=a:2,b:_0')
    west.place_token(corp, corp.next_token, check_tokenable: false)
    loop_city.place_token(corp, corp.next_token, check_tokenable: false)
    game.graph.clear
  end

  context 'with a double town' do
    let(:j81_code) { "double_town=revenue:10;#{track}" }
    let(:double_town) { game.hex_by_id('J81').tile.double_towns.first }

    it 'passes the double town once more when the far end can return, extending the head' do
      route = route_through(train, west, middle, double_town, hub, loop_city, double_town)

      expect(route.connection_data.size).to eq(5)
      expect(route.head[:left]).to eq(double_town)
      expect(route.tail[:right]).to eq(west)
      expect(route.visited_stops).to contain_exactly(west, middle, *double_town.stops, hub, loop_city)
      expect(route.revenue).to eq(110)
    end

    it 'passes the double town once more when the far end can return, extending the tail' do
      route = route_through(train, loop_city, hub, double_town, middle, west, double_town)

      expect(route.connection_data.size).to eq(5)
      expect(route.head[:left]).to eq(west)
      expect(route.tail[:right]).to eq(double_town)
      expect(route.visited_stops).to contain_exactly(west, middle, *double_town.stops, hub, loop_city)
      expect(route.revenue).to eq(110)
    end

    it 'trims the double town next to the end like a single town when no unused track leads back' do
      route = route_through(train, west, middle, double_town, hub)
      before = route.connection_data.dup
      route.touch_node(double_town)

      expect(route.connection_data).to eq(before[1..])
    end

    it 'leaves a double town two stops from both ends alone when no unused track leads back' do
      lay_code!('K82', 'city=revenue:40;path=a:1,b:_0')
      game.graph.clear
      end_city = game.hex_by_id('K82').tile.cities.first
      route = route_through(train, west, middle, double_town, hub, end_city)
      before = route.connection_data.dup
      route.touch_node(double_town)

      expect(before.size).to eq(4)
      expect(route.connection_data).to eq(before)
    end
  end

  context 'with a single town' do
    let(:j81_code) { "town=revenue:10;#{track}" }
    let(:town) { game.hex_by_id('J81').tile.towns.first }

    it 'revisits a town deep inside the route when clicked' do
      route = route_through(train, west, middle, town, hub, loop_city, town)

      expect(route.connection_data.size).to eq(5)
      expect([route.head[:left], route.tail[:right]]).to include(town)
      expect(route.visited_stops).to contain_exactly(west, middle, town, hub, loop_city)
      expect(route.revenue).to eq(110)
    end

    it 'trims the town next to the end as usual when no unused track leads back' do
      route = route_through(train, west, middle, town, hub)
      before = route.connection_data.dup
      route.touch_node(town)

      expect(route.connection_data).to eq(before[1..])
    end

    it 'leaves a town two stops from both ends alone when no unused track leads back' do
      lay_code!('K82', 'city=revenue:40;path=a:1,b:_0')
      game.graph.clear
      end_city = game.hex_by_id('K82').tile.cities.first
      route = route_through(train, west, middle, town, hub, end_city)
      before = route.connection_data.dup
      route.touch_node(town)

      expect(before.size).to eq(4)
      expect(route.connection_data).to eq(before)
    end
  end
end

describe 'G18OE double-town clicks match single-town clicks' do
  include_context 'with 18OE route helpers'

  def parity_layout(kind, j79_code:, t_exits: [1, 4], extras: {})
    fresh = new_game
    town = kind == :single ? 'town=revenue:10' : 'double_town=revenue:10'
    code = ([town] + t_exits.map { |side| "path=a:#{side},b:_0" }).join(';')
    {
      'J81' => code,
      'J79' => j79_code,
      'J83' => 'city=revenue:40;path=a:1,b:_0',
      'J77' => 'city=revenue:10;path=a:4,b:_0',
    }.merge(extras).each do |id, tile_code|
      fresh.hex_by_id(id).lay(Engine::Tile.from_code("X#{id}", :green, tile_code))
    end
    owner = fresh.corporation_by_id('A')
    fresh.hex_by_id('J79').tile.cities.first.place_token(owner, owner.next_token, check_tokenable: false)
    fresh.graph.clear
    train = fresh.trains.find { |t| t.name == '5' && !t.owner.is_a?(Engine::Corporation) }
    fresh.buy_train(owner, train, :free)
    route = Engine::Route.new(fresh, fresh.phase, train, routes: [])
    route.routes = [route]
    [fresh, route]
  end

  def click(game, route, name)
    case name
    when :town then route.touch_node(game.hex_by_id('J81').tile.towns.first)
    when :j77 then route.touch_node(game.hex_by_id('J77').tile.cities.first)
    when :j79 then route.touch_node(game.hex_by_id('J79').tile.cities.first)
    when :j83 then route.touch_node(game.hex_by_id('J83').tile.cities.first)
    end
  end

  def stop_sequence(game, route)
    town = game.hex_by_id('J81').tile.towns.first
    ids = ([route.head[:left]] + route.connection_data.map { |c| c[:right] }).map { |n| n == town ? 'T' : n.hex.id }
    ids = ids.reverse if (ids <=> ids.reverse).positive?
    [ids, route.connection_data.size]
  end

  def routes_after(clicks, **layout)
    %i[single double].map do |kind|
      game, route = parity_layout(kind, **layout)
      clicks.each { |name| click(game, route, name) }
      stop_sequence(game, route)
    end
  end

  let(:line_j79) { 'city=revenue:20;path=a:1,b:_0;path=a:4,b:_0' }

  it 'drops the end segment when the town next to an end is clicked and no track leads back' do
    single, double = routes_after(%i[j79 town j83 town], j79_code: line_j79)

    expect(double).to eq(single)
    expect(single.first).to eq(%w[J79 T])
  end

  it 'removes the far end when the city next to a double-town end is clicked after the pass is doubled back' do
    single, double = routes_after(
      %i[town j79 town j79],
      j79_code: 'city=revenue:20;path=a:3,b:_0;path=a:4,b:_0',
      t_exits: [0, 1, 2, 4, 5],
      extras: {
        'I80' => 'path=a:0,b:5',
        'K80' => 'city=revenue:30;path=a:3,b:_0;path=a:4,b:_0',
        'K82' => 'path=a:1,b:2',
      },
    )

    expect(double).to eq(single)
    expect(single.first).to eq(%w[J79 T])
  end

  it 'trims the double town at the end when the city next to it is clicked' do
    single, double = routes_after(%i[j77 j79 town j79], j79_code: line_j79)

    expect(double).to eq(single)
    expect(single.first).to eq(%w[J77 J79])
  end
end
