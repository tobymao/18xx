# frozen_string_literal: true

require 'spec_helper'
require 'engine/auto_router'
require_relative 'helpers'

describe 'G18OE double town tiles (§11.1)' do
  include G18OESpecHelpers

  let(:game) { new_game }

  let(:manifest) do
    {
      'OE1' => [:yellow, 4, [0, 3], 0.0, [1.5, 4.5], 10],
      'OE2' => [:yellow, 6, [0, 4], 0.5, [1.0, 3.0], 10],
      'OE3' => [:yellow, 2, [0, 5], 1.0, [1.0, 4.0], 10],
      'OE9' => [:green, 3, [0, 1, 3, 4], 2.0, [2.0, 5.0], 10],
      'OE10' => [:green, 3, [0, 2, 3, 4], 1.5, [1.0, 5.0], 10],
      'OE11' => [:green, 3, [0, 1, 2, 3], 0.0, [4.0, 5.0], 10],
      'OE20' => [:brown, 3, [0, 1, 2, 3], 0.0, [3.5, 5.5], 20],
      'OE21' => [:brown, 2, [0, 1, 2, 3, 4], 2.0, [0.5, 3.5], 20],
      'OE22' => [:brown, 6, [0, 1, 2, 3, 4, 5], 0.0, [1.5, 4.5], 20],
    }
  end

  let(:two_dot_hexes) { %w[J29 M26 W32 N41 Q46 U64 W46 AF53 J77 P77 AC6 C58 U6 T37 L39] }

  def tile_named(game, name)
    game.tiles.find { |t| t.name == name }
  end

  it 'defines every double-town tile from the Tile Manifest Chart' do
    manifest.each do |name, (color, count, exits, axis, revenue_locs, revenue)|
      tile = tile_named(game, name)
      expect(tile).not_to be_nil, "#{name} missing"
      expect(game.tiles.count { |t| t.name == name }).to eq(count)
      expect(tile.color).to eq(color)
      expect(tile.exits.uniq.sort).to eq(exits)
      expect(tile.double_towns.size).to eq(1)
      double_town = tile.double_towns.first
      expect(double_town.axis).to eq(axis)
      expect(double_town.revenue_locs).to eq(revenue_locs)
      expect(double_town.towns.map(&:max_revenue)).to eq([revenue, revenue])
    end
  end

  it 'prints a double town on every two-dot hex' do
    two_dot_hexes.each do |id|
      tile = game.hex_by_id(id).tile
      expect(tile.double_towns.size).to eq(1)
      expect(tile.towns.size).to eq(2)
    end
  end

  it 'lays double-town tiles only on two-dot hexes (§11.1)' do
    oe1 = tile_named(game, 'OE1')
    expect(game.upgrades_to?(game.hex_by_id('J29').tile, oe1)).to be(true)
    expect(game.upgrades_to?(game.hex_by_id('J29').tile, game.tiles.find { |t| t.name == '4' })).to be(false)
    expect(game.upgrades_to?(game.hex_by_id('H29').tile, oe1)).to be(false)
  end

  it 'upgrades a double town only to another double town' do
    oe1 = tile_named(game, 'OE1')
    oe9 = tile_named(game, 'OE9')
    oe22 = tile_named(game, 'OE22')
    expect(game.upgrades_to?(oe1, oe9)).to be(true)
    expect(game.upgrades_to?(oe9, oe22)).to be(true)
    expect(game.upgrades_to?(oe1, tile_named(game, '141'))).to be(false)
    expect(game.upgrades_to?(tile_named(game, '141'), tile_named(game, 'OE20'))).to be(false)
    separate = Engine::Tile.from_code('2t', 'green', 'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:3,b:_1')
    expect(game.upgrades_to?(oe1, separate)).to be(false)
  end

  def lay_tile!(game, hex_id, name, rotation)
    tile = game.tiles.find { |t| t.name == name && !t.hex }
    tile.rotate!(rotation)
    game.hex_by_id(hex_id).lay(tile)
    tile
  end

  def buy_train!(game, corporation, name)
    train = game.trains.find { |t| t.name == name && !t.owner.is_a?(Engine::Corporation) }
    game.buy_train(corporation, train, :free)
    train
  end

  def route_through(game, train, *nodes)
    route = Engine::Route.new(game, game.phase, train, routes: [])
    route.routes = [route]
    nodes.each { |node| route.touch_node(node) }
    route
  end

  def expect_cities_around_towns(route, cities, towns)
    stops = route.visited_stops
    expect(stops.size).to eq(4)
    expect([stops.first, stops.last]).to contain_exactly(*cities)
    expect(stops[1..2]).to contain_exactly(*towns)
  end

  context 'with a double town between two cities' do
    let(:corp) { game.corporation_by_id('A') }
    let(:j77) { game.hex_by_id('J77') }
    let(:west) { game.hex_by_id('I76').tile.cities.first }
    let(:east) { game.hex_by_id('K78').tile.cities.first }
    let(:a) { j77.tile.towns[0] }
    let(:b) { j77.tile.towns[1] }
    let(:local) { buy_train!(game, corp, '2+2') }
    let(:express) { buy_train!(game, corp, '3') }

    before do
      lay_tile!(game, 'J77', 'OE1', 2)
      lay_tile!(game, 'I76', '57', 2)
      lay_tile!(game, 'K78', '57', 2)
      west.place_token(corp, corp.next_token, check_tokenable: false)
      game.graph.clear
    end

    describe 'graph' do
      it 'connects both towns and the far city' do
        expect(game.graph.connected_nodes(corp).keys).to include(a, b, east)
        expect(game.graph.connected_hexes(corp).keys).to include(j77, game.hex_by_id('K78'))
      end

      it 'walks the entry twin paths, the internal path and one exit path' do
        paths = game.graph.connected_paths(corp).keys.select { |path| path.hex == j77 }
        by_exit = paths.group_by { |path| path.edges.map(&:num) }

        expect(j77.tile.paths.size).to eq(5)
        expect(by_exit.transform_values(&:size)).to eq([2] => 2, [] => 1, [5] => 1)
      end

      it 'reaches the far city on a walk through both towns' do
        records = []
        west.walk(corporation: corp) do |path, _vp, visited|
          records << { nodes: path.nodes, visited: visited.keys }
        end

        far = records.select { |record| record[:nodes].include?(east) }
        expect(far).not_to be_empty
        expect(far.any? { |record| record[:visited].include?(a) && record[:visited].include?(b) }).to be(true)
      end

      it 'every walk from the city to the far city passes both towns' do
        records = []
        west.walk(corporation: corp) do |path, _vp, visited|
          records << visited.keys if path.nodes.include?(east)
        end

        expect(records).not_to be_empty
        expect(records).to all(include(a, b))
      end

      it 'a walk entering a town from an exit continues only over the internal path' do
        leaves_early = []
        west.walk(corporation: corp) do |path, _vp, visited|
          town = path.nodes.find { |node| [a, b].include?(node) && visited[node] }
          next if !town || path.edges.empty?

          other = town == a ? b : a
          leaves_early << path unless visited[other]
        end

        expect(leaves_early).to be_empty
      end

      it 'a walk starting at either town passes the other town before leaving' do
        [[a, b], [b, a]].each do |start, other|
          visited_at_exit = []
          start.walk(corporation: corp) do |path, _vp, visited|
            visited_at_exit << visited.keys if path.nodes.include?(east) || path.nodes.include?(west)
          end

          expect(visited_at_exit).not_to be_empty
          expect(visited_at_exit).to all(include(other))
        end
      end

      it 'reaches each town from the other over the internal path' do
        arrivals = []
        [a, b].each do |start|
          start.walk(corporation: corp) do |path, _vp, visited|
            next if path.nodes.sort_by(&:object_id) != [a, b].sort_by(&:object_id)

            from = path.nodes.find { |node| visited[node] }
            arrivals << [from, (path.nodes - [from]).first]
          end
        end

        expect(arrivals).to include([a, b], [b, a])
      end
    end

    describe 'routing a train' do
      it 'runs a train through both towns' do
        route = route_through(game, local, west, a, b, east)

        expect_cities_around_towns(route, [west, east], [a, b])
        expect(route.revenue).to eq(60)
      end

      it 'runs a train through both towns in either order' do
        route = route_through(game, local, west, b, a, east)

        expect_cities_around_towns(route, [west, east], [a, b])
        expect(route.revenue).to eq(60)
      end

      it 'rejects a train that passes only the first town' do
        route = route_through(game, local, west, a, east)

        expect { route.revenue }.to raise_error(Engine::GameError, /both towns/)
      end

      it 'rejects a train that passes only the second town' do
        route = route_through(game, local, west, b, east)

        expect { route.revenue }.to raise_error(Engine::GameError, /both towns/)
      end

      it 'accepts a route that ends at one town of the double town' do
        route = route_through(game, local, west, a)

        expect(route.revenue).to eq(20 + 10)
      end

      it 'accepts a route that starts at one town of the double town' do
        route = route_through(game, local, a, west)

        expect(route.revenue).to eq(20 + 10)
      end

      it 'accepts a route that ends at the double town after both towns' do
        route = route_through(game, local, west, a, b)

        expect(route.revenue).to eq(40)
      end

      it 'auto-router candidates that pass through the double town take both towns' do
        routes = Engine::AutoRouter.new(game).path([local], corp).first[local]
        full = routes.select { |route| [west, a, b, east].all? { |node| route.visited_stops.include?(node) } }

        expect(full).not_to be_empty
        expect(full.map { |route| route.visited_stops.size }.uniq).to eq([4])
        routes.each do |route|
          visited = route.visited_stops
          next if visited.first == a || visited.first == b || visited.last == a || visited.last == b

          expect(visited.include?(a)).to eq(visited.include?(b))
        end
      end
    end

    describe 'removing the stops of a one-segment route' do
      it 'drops the far end of a route that has a single segment' do
        route = route_through(game, local, west, a)

        expect { route.touch_node(a) }.not_to raise_error
        expect(route.connection_data).to be_empty
      end

      it 'drops both towns from the end of a route' do
        route = route_through(game, local, west, a, b)

        expect { [b, a].each { |town| route.touch_node(town) } }.not_to raise_error
        expect(route.connection_data).to be_empty
        expect(route.last_node).to eq(west)
      end
    end

    describe 'revenue' do
      let(:t1) { lay_tile!(game, 'H29', '4', 0).towns.first }
      let(:t2) { lay_tile!(game, 'J17', '4', 0).towns.first }

      def stubbed(train, *nodes)
        connection_data = nodes.each_cons(2).map { |l, r| { left: l, right: r, chain: { nodes: [l, r], paths: [] } } }
        instance_double(Engine::Route, corporation: corp, phase: game.phase, train: train, connection_data: connection_data)
      end

      it 'counts both towns for a 2+2 (PB 4.3)' do
        route = stubbed(local, west, a, b)
        stops = game.compute_stops(route)

        expect(stops).to contain_exactly(west, a, b)
        expect(game.revenue_for(route, stops)).to eq(20 + 20)
      end

      it 'counts one town when only one town slot is left' do
        route = stubbed(local, west, t1, t2, a, b)
        stops = game.compute_stops(route)

        expect(stops.size).to eq(4)
        expect(game.revenue_for(route, stops)).to eq(20 + 30)
      end

      it 'caps an express train at its three places, letting towns replace cities (§11.3.9)' do
        route = route_through(game, express, west, a, b, east)

        expect(route.revenue).to eq(20 + 20 + 10)
      end
    end
  end

  context 'with a double town between a city and a single town' do
    let(:corp) { game.corporation_by_id('A') }
    let(:city) { game.hex_by_id('X45').tile.cities.first }
    let(:far_town) { game.hex_by_id('V47').tile.towns.first }
    let(:double_town) { game.hex_by_id('W46').tile.towns }

    before do
      lay_tile!(game, 'W46', 'OE1', 0)
      lay_tile!(game, 'X45', '621', 0)
      lay_tile!(game, 'V47', '4', 0)
      city.place_token(corp, corp.next_token, check_tokenable: false)
      game.graph.clear
    end

    it 'reaches a town beyond the double town through both towns' do
      expect(game.graph.connected_nodes(corp).keys).to include(*double_town, far_town)

      walks = []
      city.walk(corporation: corp) do |path, _vp, visited|
        walks << { nodes: path.nodes, visited: visited.keys }
      end

      through_both = walks.select do |walk|
        walk[:nodes].include?(far_town) && double_town.all? { |town| walk[:visited].include?(town) }
      end
      expect(through_both).not_to be_empty
    end
  end

  context 'with a brown double town on every exit' do
    let(:corp) { game.corporation_by_id('A') }
    let(:j77) { game.hex_by_id('J77') }
    let(:oe22) { lay_tile!(game, 'J77', 'OE22', 0) }
    let(:a) { oe22.towns[0] }
    let(:b) { oe22.towns[1] }
    let(:local) { buy_train!(game, corp, '2+2') }
    let(:neighbours) { { 0 => 'K76', 1 => 'J75', 2 => 'I76', 3 => 'I78', 4 => 'J79', 5 => 'K78' } }

    def edge_path(edge, town)
      path = oe22.paths.find { |p| p.edges.map(&:num) == [edge] && p.nodes.include?(town) }
      expect(path).not_to be_nil, "no path from exit #{edge} to a town"
      path
    end

    def internal_path
      path = oe22.paths.find { |p| p.edges.empty? }
      expect(path).not_to be_nil
      path
    end

    def through(edge_in, first, second, edge_out)
      before = edge_path(edge_in, first)
      middle = internal_path
      after = edge_path(edge_out, second)
      expect([before, middle, after].each_cons(2).all? { |x, y| (x.nodes & y.nodes).any? }).to be(true)
      outer = Object.new
      connection_data = [
        { left: outer, right: first, chain: { nodes: [outer, first], paths: [before] } },
        { left: first, right: second, chain: { nodes: [first, second], paths: [middle] } },
        { left: second, right: outer, chain: { nodes: [second, outer], paths: [after] } },
      ]
      Engine::Route.new(game, game.phase, local, routes: [], connection_data: connection_data)
    end

    def past_one(edge_in, town, edge_out)
      before = edge_path(edge_in, town)
      after = edge_path(edge_out, town)
      outer = Object.new
      connection_data = [
        { left: outer, right: town, chain: { nodes: [outer, town], paths: [before] } },
        { left: town, right: outer, chain: { nodes: [town, outer], paths: [after] } },
      ]
      Engine::Route.new(game, game.phase, local, routes: [], connection_data: connection_data)
    end

    def lay_neighbour!(edge)
      lay_tile!(game, neighbours[edge], '57', (edge + 3) % 6)
    end

    it 'passes through both towns between any two exits of OE22' do
      oe22
      pairs = (0..5).to_a.permutation(2)

      expect(pairs.size).to eq(30)
      pairs.each do |e, f|
        [[a, b], [b, a]].each do |first, second|
          expect { through(e, first, second, f).check_double_towns! }.not_to raise_error
        end
        [a, b].each do |town|
          expect { past_one(e, town, f).check_double_towns! }.to raise_error(Engine::GameError, /both towns/)
        end
      end
    end

    [3, 1, 0].each do |other|
      context "between exits 2 and #{other} on real track" do
        let(:west) { game.hex_by_id('I76').tile.cities.first }
        let(:far) { game.hex_by_id(neighbours[other]).tile.cities.first }

        before do
          oe22
          lay_neighbour!(2)
          lay_neighbour!(other)
          west.place_token(corp, corp.next_token, check_tokenable: false)
          game.graph.clear
        end

        it 'scores a route through both towns in either order' do
          [[a, b], [b, a]].each do |first, second|
            route = route_through(game, local, west, first, second, far)

            expect(route.visited_stops.size).to eq(4)
            expect(route.revenue).to eq(20 + 20 + 20 + 20)
          end
        end

        it 'rejects a route that passes only one town' do
          [a, b].each do |town|
            route = route_through(game, local, west, town, far)

            expect { route.revenue }.to raise_error(Engine::GameError, /both towns/)
          end
        end
      end
    end

    context 'with cities on several neighbours' do
      let(:west) { game.hex_by_id('I76').tile.cities.first }
      let(:others) { [3, 1, 5].map { |edge| game.hex_by_id(neighbours[edge]).tile.cities.first } }

      before do
        oe22
        [2, 3, 1, 5].each { |edge| lay_neighbour!(edge) }
        west.place_token(corp, corp.next_token, check_tokenable: false)
        game.graph.clear
      end

      it 'passes both towns on every walk from I76 to a neighbouring city' do
        records = Hash.new { |hash, city| hash[city] = [] }
        west.walk(corporation: corp) do |path, _vp, visited|
          others.each { |city| records[city] << visited.keys if path.nodes.include?(city) }
        end

        others.each do |city|
          expect(records[city]).not_to be_empty
          expect(records[city]).to all(include(a, b))
        end
      end

      it 'reaches every neighbouring city through both towns of OE22' do
        expect(game.graph.connected_nodes(corp).keys).to include(a, b, *others)

        walks = []
        west.walk(corporation: corp) do |path, _vp, visited|
          walks << { nodes: path.nodes, visited: visited.keys }
        end

        others.each do |city|
          through_both = walks.select do |walk|
            walk[:nodes].include?(city) && walk[:visited].include?(a) && walk[:visited].include?(b)
          end
          expect(through_both).not_to be_empty, "no walk from I76 to #{city.hex.id} through both towns"
        end
      end
    end

    context 'with two routes crossing the same exit' do
      let(:west) { game.hex_by_id('I76').tile.cities.first }
      let(:east) { game.hex_by_id('K78').tile.cities.first }
      let(:south) { game.hex_by_id('I78').tile.cities.first }

      before do
        oe22
        [2, 3, 5].each { |edge| lay_neighbour!(edge) }
        other = game.corporation_by_id('C')
        west.place_token(corp, corp.next_token, check_tokenable: false)
        east.place_token(other, other.next_token, check_tokenable: false)
        game.graph.clear
      end

      it 'treats the twin paths on an exit as one track' do
        other = game.corporation_by_id('C')
        first = Engine::Route.new(game, game.phase, local, routes: [])
        second = Engine::Route.new(game, game.phase, buy_train!(game, other, '2+2'), routes: [])
        [south, a, b, west].each { |node| first.touch_node(node) }
        [east, a, b, south].each { |node| second.touch_node(node) }
        [first, second].each { |route| route.routes = [first, second] }
        on_exit3 = ->(route) { route.paths.select { |path| path.hex == j77 && path.edges.map(&:num) == [3] } }

        expect(on_exit3.call(first).size).to eq(1)
        expect(on_exit3.call(second).size).to eq(1)
        expect(on_exit3.call(first)).not_to eq(on_exit3.call(second))
        expect { second.revenue }.to raise_error(Engine::GameError, /Route cannot reuse track on J77/)
      end
    end
  end
end
