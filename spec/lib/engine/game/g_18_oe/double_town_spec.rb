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
      expect(tile.towns).to eq(tile.double_towns)
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
    let(:double_town) { j77.tile.double_towns.first }
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
      it 'connects the double town and the far city' do
        expect(game.graph.connected_nodes(corp).keys).to include(double_town, east)
        expect(game.graph.connected_hexes(corp).keys).to include(j77, game.hex_by_id('K78'))
      end

      it 'walks one path per exit into the double town' do
        paths = game.graph.connected_paths(corp).keys.select { |path| path.hex == j77 }

        expect(j77.tile.paths.size).to eq(2)
        expect(paths.size).to eq(2)
        expect(paths.map(&:nodes)).to all(eq([double_town]))
      end
    end

    describe 'routing a train' do
      it 'runs a train through the double town' do
        route = route_through(game, local, west, double_town, east)

        expect(route.visited_stops).to contain_exactly(west, *double_town.stops, east)
        expect(route.revenue).to eq(60)
      end

      it 'pays both halves when a route ends on the double town' do
        route = route_through(game, local, west, double_town)

        expect(route.revenue).to eq(40)
      end

      it 'auto-router candidates through the double town count both halves' do
        routes = Engine::AutoRouter.new(game).path([local], corp).first[local]
        full = routes.select { |route| route.visited_stops.include?(east) }

        expect(full).not_to be_empty
        expect(full.map { |route| route.visited_stops.size }.uniq).to eq([4])
      end
    end

    describe 'removing the stops of a one-segment route' do
      it 'drops the double town from the end of a route with one click' do
        route = route_through(game, local, west, double_town)
        route.touch_node(double_town)

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

      it 'visits both halves of the double town' do
        route = stubbed(local, west, double_town)

        expect(game.visited_stops(route)).to eq([west, *double_town.stops])
      end

      it 'counts both halves for a 2+2 (PB 4.3)' do
        route = stubbed(local, west, double_town)
        stops = game.compute_stops(route)

        expect(stops).to contain_exactly(west, *double_town.stops)
        expect(game.revenue_for(route, stops)).to eq(20 + 20)
      end

      it 'counts one half when only one town slot is left' do
        route = stubbed(local, west, t1, t2, double_town)
        stops = game.compute_stops(route)

        expect(stops.size).to eq(4)
        expect((stops & double_town.stops).size).to eq(1)
        expect(game.revenue_for(route, stops)).to eq(20 + 30)
      end

      it 'caps an express train at its three places, letting halves replace cities (§11.3.9)' do
        route = route_through(game, express, west, double_town, east)

        expect(route.revenue).to eq(20 + 20 + 10)
      end
    end
  end

  context 'with a double town between a city and a single town' do
    let(:corp) { game.corporation_by_id('A') }
    let(:city) { game.hex_by_id('X45').tile.cities.first }
    let(:far_town) { game.hex_by_id('V47').tile.towns.first }
    let(:double_town) { game.hex_by_id('W46').tile.double_towns.first }

    before do
      lay_tile!(game, 'W46', 'OE1', 0)
      lay_tile!(game, 'X45', '621', 0)
      lay_tile!(game, 'V47', '4', 0)
      city.place_token(corp, corp.next_token, check_tokenable: false)
      game.graph.clear
    end

    it 'reaches a town beyond the double town' do
      expect(game.graph.connected_nodes(corp).keys).to include(double_town, far_town)
    end
  end

  context 'with a brown double town on every exit' do
    let(:corp) { game.corporation_by_id('A') }
    let(:j77) { game.hex_by_id('J77') }
    let(:oe22) { lay_tile!(game, 'J77', 'OE22', 0) }
    let(:double_town) { oe22.double_towns.first }
    let(:local) { buy_train!(game, corp, '2+2') }
    let(:neighbours) { { 0 => 'K76', 1 => 'J75', 2 => 'I76', 3 => 'I78', 4 => 'J79', 5 => 'K78' } }

    def lay_neighbour!(edge)
      lay_tile!(game, neighbours[edge], '57', (edge + 3) % 6)
    end

    it 'joins every exit of OE22 to the double town' do
      expect(oe22.paths.map(&:exits).flatten.sort).to eq([0, 1, 2, 3, 4, 5])
      expect(oe22.paths.map(&:nodes)).to all(eq([double_town]))
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

        it 'scores a route through the double town' do
          route = route_through(game, local, west, double_town, far)

          expect(route.visited_stops.size).to eq(4)
          expect(route.revenue).to eq(20 + 20 + 20 + 20)
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

      it 'reaches every neighbouring city through the double town' do
        expect(game.graph.connected_nodes(corp).keys).to include(double_town, *others)
      end
    end
  end
end
