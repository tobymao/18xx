# frozen_string_literal: true

require 'spec_helper'
require 'engine/auto_router'
require_relative 'route_helpers'

describe 'G18OE auto-router over sea (§11.3.4, §11.3.8)' do
  include_context 'with 18OE route helpers'

  let(:corp) { game.corporation_by_id('DSJ') }
  let(:three) { buy_train!('3') }
  let(:four) { buy_train!('4') }

  def routes_for(train, corporation = corp, trains: [train])
    Engine::AutoRouter.new(game).path(trains, corporation).first[train]
  end

  before { baltic! }

  it 'turns a yielded link into a pathless chain and keeps the route (core link assembly)' do
    token!('I50', corp)
    token!('I52', corp)
    link = game.sea_links(city('I50'), city('I52'), corp).first[:crossing]
    allow(game.graph).to receive(:walk_token).and_wrap_original do |original, node, **opts, &block|
      if opts[:links]
        block.call(link, { link => true }, {})
      else
        original.call(node, **opts, &block)
      end
    end
    routes = routes_for(three)

    expect(game.graph).to have_received(:walk_token).with(anything, hash_including(links: true)).at_least(:once)

    expect(routes.size).to eq(1)
    expect(routes.first.chains).to eq([link.chain])
    expect(routes.first.visited_stops).to contain_exactly(city('I50'), city('I52'))
    expect(routes.first.bitfield).to eq([0])
  end

  it 'gives a ferry-only route an empty bitfield so it conflicts with nothing' do
    token!('I52', corp)
    route = explicit_route(three, town('H55'), town('K60'))

    expect(Engine::AutoRouter.new(game).bitfield_from_connection(route.connection_data, Hash.new { |h, k| h[k] = 0 })).to eq([0])
  end

  it 'offers a route that ends with a crossing (row 17)' do
    token!('I50', corp)
    token!('I52', corp)
    routes = routes_for(four)
    crossing_routes = routes.select { |route| route.chains.any? { |c| c[:paths].empty? } }

    expect(crossing_routes.map(&:visited_stops)).to include(contain_exactly(city('I50'), city('I52')))
    full = contain_exactly(city('I50'), city('I52'), town('H55'), town('K60'), city('J63'))
    expect(crossing_routes.map(&:visited_stops)).to include(full)
  end

  it 'departs from a pathless root city and from a port section reached by land (row 17a)' do
    bjv = game.corporation_by_id('BJV')
    token!('C48', bjv)
    token!('J63', bjv)
    train = game.trains.find { |t| t.name == '4' && !t.owner.is_a?(Engine::Corporation) }
    game.buy_train(bjv, train, :free)
    stops = routes_for(train, bjv).map(&:visited_stops)

    expect(stops).to include(contain_exactly(city('C48'), city('I50')))
    expect(stops).to include(contain_exactly(city('J63'), town('K60'), city('C48')))
  end

  it 'lands at New York and makes its hex clickable (row 12b)' do
    token!('I50', corp)
    five = buy_train!('5')

    expect(game.graph.reachable_hexes(corp)[game.hex_by_id('N1')]).to be(true)
    expect(routes_for(five).map(&:visited_stops)).to include(contain_exactly(city('I50'), offboard('N1')))
    expect(game.graph.connected_nodes(corp)).not_to have_key(offboard('N1'))
  end

  it 'returns ferry routes for two trains whose bitfields do not conflict (row 18)' do
    token!('I52', corp)
    token!('J63', corp)
    train_routes = Engine::AutoRouter.new(game).path([three, four], corp).first
    first = train_routes[three].find { |r| r.visited_stops.to_set == [city('I52'), town('H55'), town('K60')].to_set }
    second = train_routes[four].find { |r| r.visited_stops.to_set == [city('J63'), town('K60'), town('H55')].to_set }

    expect(first).not_to be_nil
    expect(second).not_to be_nil
    expect(first.bitfield.zip(second.bitfield).all? { |a, b| ((a || 0) & (b || 0)).zero? }).to be(true)
    expect { game.check_overlap([first, second]) }.not_to raise_error
  end

  it 'never offers two adjacent crossings (row 19)' do
    token!('I50', corp)
    token!('I52', corp)
    adjacent = routes_for(four).any? do |route|
      route.chains.each_cons(2).any? { |a, b| a[:crossing]&.kind == :crossing && b[:crossing]&.kind == :crossing }
    end

    expect(adjacent).to be(false)
  end

  describe 'with a port authority' do
    let(:two_plus_two) { buy_train!('2+2') }
    let(:other_train) { buy_train!('2+2') }

    before do
      token!('I52', corp)
      fund!(game, corp, 125)
      game.buy_port_authority!(corp, :north_sea)
    end

    it 'finds a crossing longer than the train with a port authority' do
      token!('I50', corp)
      stops = routes_for(two_plus_two).map(&:visited_stops)

      expect(stops).to include(contain_exactly(city('I50'), city('M28')))
    end

    it 'does not pick two trains that together need more than the pool' do
      token!('J63', corp)
      long = explicit_route(two_plus_two, city('I50'), town('K60'), city('J63'))
      other = explicit_route(other_train, city('I52'), town('H55'), city('I50'))
      routes = [long, other]
      routes.each { |route| route.routes = routes }

      expect(Engine::AutoRouter.new(game).real_revenue(routes)).to eq(-1)
    end
  end

  it 'bounds the number of paths explored on a busy coast (row 20)' do
    city('I20').reservations.clear
    %w[I50 I52 J63 C48 B41 M28 AE72 AA20 I20 N31].each { |hex_id| token!(hex_id, corp) }
    lay_code!('AA20', 'city=revenue:30;path=a:5,b:_0')
    lay_code!('AB27', 'city=revenue:20;path=a:1,b:_0;path=a:0,b:_0')
    lay_code!('D41', 'town=revenue:10;path=a:0,b:_0;path=a:3,b:_0')
    five = buy_train!('5')
    paths = 0
    path_budget = 25_000
    allow(game.graph).to receive(:walk_token).and_wrap_original do |original, node, **opts, &block|
      next original.call(node, **opts, &block) unless opts[:links]

      original.call(node, **opts) do |*args|
        paths += 1
        raise "Sea auto-router exceeded #{path_budget} path visits" if paths > path_budget

        block.call(*args)
      end
    end

    routes, = Engine::AutoRouter.new(game).path([three, four, five], corp, path_timeout: Float::INFINITY)

    expect(routes.keys).to contain_exactly(three, four, five)
  end

  it 'departs by the Edinburgh ferry from the hex a crossing landed on (§11.3.7)' do
    lay_code!('D41', 'town=revenue:10;path=a:0,b:_0;path=a:3,b:_0')
    token!('B41', corp)
    stops = routes_for(three).map(&:visited_stops)

    expect(stops).to include(contain_exactly(town('D41'), city('B41'), city('G26')))
  end

  it 'rides the public Edinburgh ferry from a city reached by land without an Edinburgh token (§11.3.7)' do
    lay_code!('H25', 'city=revenue:20;path=a:3,b:_0')
    lay_code!('G26', 'city=revenue:20;path=a:0,b:_0')
    token!('H25', corp)
    stops = routes_for(four).map(&:visited_stops)

    expect(stops).to include(contain_exactly(city('H25'), city('G26'), city('B41')))
  end

  it 'walks the public Edinburgh ferry from a root reaching Edinburgh by land without a token there (§11.3.7)' do
    lay_code!('H25', 'city=revenue:20;path=a:3,b:_0')
    lay_code!('G26', 'city=revenue:20;path=a:0,b:_0')
    token!('H25', corp)
    ferries = []
    game.graph.walk_token(city('H25'), corporation: corp, skip_paths: nil, links: true) do |path, _visited_paths, _visited|
      ferries << path if path.respond_to?(:kind) && path.kind == :ferry
      nil
    end

    expect(ferries.map { |ferry| ferry.nodes.map(&:hex).map(&:id) }).to include(%w[G26 B41])
  end

  it 'never asks for sea links while computing connectivity' do
    token!('I50', corp)
    calls = []
    original = game.graph.method(:walk_token)
    allow(game.graph).to receive(:walk_token) do |node, **opts, &block|
      calls << opts
      original.call(node, **opts, &block)
    end
    game.graph.clear
    game.graph.compute(corp)

    expect(calls).not_to be_empty
    expect(calls.map { |opts| opts[:links] }).to all(be_falsey)
  end
end
