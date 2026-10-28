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

      it 'walks every twin path and the internal path' do
        paths = game.graph.connected_paths(corp).keys.select { |path| path.hex == j77 }
        expect(paths).to include(*j77.tile.paths)
        expect(j77.tile.paths.size).to eq(5)
      end

      it 'reaches the far city on a walk through both towns' do
        records = []
        hops = []
        west.walk(corporation: corp) do |path, _vp, visited|
          records << visited.keys
          hops << path.nodes if path.nodes.include?(a) && path.nodes.include?(b)
        end

        expect(records.any? { |nodes| nodes.include?(east) && nodes.include?(a) && nodes.include?(b) }).to be(true)
        expect(hops).not_to be_empty
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

      it 'rejects a route that ends at one town of the double town' do
        route = route_through(game, local, west, a)

        expect { route.revenue }.to raise_error(Engine::GameError, /both towns/)
      end

      it 'accepts a route that ends at the double town after both towns' do
        route = route_through(game, local, west, a, b)

        expect(route.revenue).to eq(40)
      end

      it 'auto-router candidates always take both towns' do
        routes = Engine::AutoRouter.new(game).path([local], corp).first[local]
        full = routes.select { |route| [west, a, b, east].all? { |node| route.visited_stops.include?(node) } }

        expect(full).not_to be_empty
        expect(full.map { |route| route.visited_stops.size }.uniq).to eq([4])
        routes.each do |route|
          visited = route.visited_stops
          expect(visited.include?(a)).to eq(visited.include?(b))
        end
      end

      it 'treats the twin paths on an exit as one track' do
        paths = j77.tile.paths.select { |path| path.edges.map(&:num) == [2] }
        first = instance_double(Engine::Route, paths: [paths[0]])
        second = instance_double(Engine::Route, paths: [paths[1]])

        expect(paths.size).to eq(2)
        expect { game.check_overlap([first, second]) }.to raise_error(Engine::GameError, /cannot reuse track/)
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

  context 'with a brown double town on every exit' do
    let(:corp) { game.corporation_by_id('A') }
    let(:oe22) { lay_tile!(game, 'J77', 'OE22', 0) }
    let(:a) { oe22.towns[0] }
    let(:b) { oe22.towns[1] }
    let(:local) { buy_train!(game, corp, '2+2') }

    def leg(game, train, edge_in, first, second, edge_out)
      enter = oe22.paths.find { |path| path.edges.map(&:num) == [edge_in] && path.nodes.include?(first) }
      middle = oe22.paths.find { |path| path.edges.empty? }
      leave = oe22.paths.find { |path| path.edges.map(&:num) == [edge_out] && path.nodes.include?(second) }
      chain = { nodes: [first, second], paths: [enter, middle, leave] }
      Engine::Route.new(game, game.phase, train, routes: [], connection_data: [{ left: first, right: second, chain: chain }])
    end

    def single(game, train, edge_in, only)
      enter = oe22.paths.find { |path| path.edges.map(&:num) == [edge_in] && path.nodes.include?(only) }
      chain = { nodes: [only, only], paths: [enter] }
      Engine::Route.new(game, game.phase, train, routes: [], connection_data: [{ left: only, right: only, chain: chain }])
    end

    it 'passes through both towns between any two exits of OE22' do
      oe22
      pairs = (0..5).to_a.permutation(2)

      expect(pairs.size).to eq(30)
      pairs.each do |e, f|
        [[a, b], [b, a]].each do |first, second|
          expect { leg(game, local, e, first, second, f).check_double_towns! }.not_to raise_error
        end
        expect { single(game, local, e, a).check_double_towns! }.to raise_error(Engine::GameError, /both towns/)
        expect { single(game, local, e, b).check_double_towns! }.to raise_error(Engine::GameError, /both towns/)
      end
    end
  end
end
