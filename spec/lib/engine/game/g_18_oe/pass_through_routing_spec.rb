# frozen_string_literal: true

require 'spec_helper'
require_relative 'route_helpers'

describe 'G18OE pass-through token routing (§14.5, §11.3.1, §11.3.4, §11.2.2)' do
  include_context 'with 18OE route helpers'

  let(:cctc) { game.company_by_id('CCTC') }
  let(:shtc) { game.company_by_id('SHTC') }
  let(:other) { game.corporation_by_id('B') }
  let(:j81) { town('J81') }

  def lay_line!
    lay_code!('J79', 'city=revenue:20;path=a:4,b:_0;path=a:5,b:_0')
    lay_code!('K80', 'city=revenue:30;path=a:2,b:_0;path=a:3,b:_0')
    lay_code!('J81', 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0')
    lay_code!('J83', 'city=revenue:40;path=a:1,b:_0')
  end

  def station!(city, corporation)
    city.place_token(corporation, corporation.next_token, check_tokenable: false)
    game.graph.clear
  end

  def pass_through!(company, corporation, city)
    game.place_pass_through_token!(company, corporation, city)
    game.graph.clear
  end

  context 'on a line J79 - K80 - J81 - J83' do
    before do
      lay_line!
      station!(c1, corp)
    end

    it 'lets the owning RR run through a city full of other RRs tokens (free passage)' do
      station!(c2, other)
      pass_through!(cctc, corp, c2)

      expect { route_through(buy_train!('5'), c1, c2, j81, c3).revenue }.not_to raise_error
    end

    it 'does not count the pass-through city toward the city limit (A - X - B on a 2+2 train)' do
      pass_through!(cctc, corp, c2)
      route = route_through(buy_train!('2+2'), c1, c2, j81, c3)

      expect(route.revenue).to eq(70)
      expect(game.route_distance_str(route)).to eq('2')
    end

    it 'counts the city toward the city limit for a RR without the token' do
      station!(c2, corp)

      expect { route_through(buy_train!('2+2'), c1, c2, j81, c3).revenue }.to raise_error(Engine::RouteTooLong)
    end

    it 'pays no revenue for the pass-through city' do
      pass_through!(cctc, corp, c2)

      expect(route_through(buy_train!('5'), c1, c2, j81, c3).revenue).to eq(70)
    end

    it 'does not accept the pass-through token as the only token on the route' do
      pass_through!(cctc, corp, c2)

      expect { route_through(buy_train!('5'), c2, j81, c3).revenue }.to raise_error(Engine::NoToken)
    end

    it 'rejects a route of one station city and the pass-through city (needs two stops)' do
      pass_through!(cctc, corp, c2)

      expect { route_through(buy_train!('5'), c1, c2).revenue }.to raise_error(Engine::RouteTooShort)
    end

    it 'accepts a station city, the pass-through city and a town' do
      pass_through!(cctc, corp, c2)

      expect(route_through(buy_train!('5'), c1, c2, j81).revenue).to eq(30)
    end
  end

  context 'with only a pass-through token' do
    before do
      lay_line!
      pass_through!(cctc, other, c2)
    end

    it 'does not use the token as a graph root' do
      expect(game.graph.connected_nodes(other)).to be_empty
      expect(game.graph.reachable_hexes(other)).to be_empty
    end

    it 'offers no cities to token and no hexes to lay track from the pass-through city' do
      expect(game.token_graph_for_entity(other).tokenable_cities(other)).to be_empty
      expect(game.graph.connected_hexes(other)).to be_empty
    end

    it 'does not use the token as a merge connectivity root' do
      expect(game.merge_graph.connected_nodes(other)).to be_empty
    end
  end

  describe 'sea crossings (§11.3.4)' do
    let(:dsj) { game.corporation_by_id('DSJ') }

    before { baltic! }

    it 'uses a pass-through token city as a private port' do
      lay_code!('I52', 'city=revenue:20;path=a:0,b:_0')
      expect(game.sea_links(city('I50'), city('I52'), dsj)).to be_empty

      pass_through!(shtc, dsj, city('I52'))

      expect(game.sea_links(city('I50'), city('I52'), dsj).size).to eq(1)
    end

    it 'does not use a pass-through token city as a sea connectivity root' do
      pass_through!(shtc, dsj, city('I50'))

      expect(game.graph.sea_connectivity(dsj).landing_nodes).to be_empty
      expect(game.graph.sea_connectivity(dsj).landing_offboards).to be_empty
    end

    it 'gives a ferry end no reduction for the Central Circle token but does for the Star Harbor token' do
      train = game.trains.find { |t| t.name == '3' && !t.owner.is_a?(Engine::Corporation) }
      game.buy_train(dsj, train, :free)
      route = -> { explicit_route(train, city('A56'), city('A64')) }
      baseline = game.sea_distance(route.call)

      pass_through!(cctc, dsj, city('A64'))
      expect(game.sea_distance(route.call)).to eq(baseline)

      pass_through!(shtc, dsj, city('A56'))
      expect(game.sea_distance(route.call)).to be < baseline
    end

    it 'reduces the sea zones of a crossing ending at a pass-through token city' do
      corp = dsj
      train = game.trains.find { |t| t.name == '3' && !t.owner.is_a?(Engine::Corporation) }
      game.buy_train(corp, train, :free)
      pass_through!(shtc, corp, city('J63'))

      expect(game.sea_distance(explicit_route(train, town('H55'), city('J63')))).to eq(0)
    end
  end

  describe 'Lille (§11.2.2)' do
    let(:lnwr) { game.corporation_by_id('LNWR') }
    let(:lille) { game.lille_city }
    let(:london) { game.hex_by_id('M28').tile.cities.first }
    let(:west) { game.hex_by_id('O30').tile.cities.first }

    before do
      %w[N31 O30 O32].zip([['OE33', 0], ['57', 0], ['9', 2]]).each do |hex_id, (name, rotation)|
        tile = game.tiles.find { |t| t.name == name && !t.hex }
        tile.rotate!(rotation)
        game.hex_by_id(hex_id).lay(tile)
      end
      %w[PLM MZA].first(lille.normal_slots).each do |id|
        holder = game.corporation_by_id(id)
        lille.place_token(holder, holder.next_token, free: true, check_tokenable: false)
      end
      game.remove_wcf_placeholder!
      wcf_owner = game.corporation_by_id('B')
      lille.place_token(wcf_owner, wcf_owner.next_token, free: true, check_tokenable: false, extra_slot: true)
      west.place_token(lnwr, lnwr.next_token, free: true, check_tokenable: false)
      game.graph.clear
    end

    it 'blocks a RR without a Lille token once the WCF token is placed' do
      expect(game.graph.reachable_hexes(lnwr)[game.hex_by_id('M28')]).to be_nil
    end

    it 'lets the RR with the Central Circle token on Lille ferry to London and pass Lille' do
      pass_through!(cctc, lnwr, lille)

      reachable = game.graph.reachable_hexes(lnwr)
      expect(reachable[game.hex_by_id('M28')]).to be(true)
      expect(reachable[game.hex_by_id('O32')]).to be(true)
      expect(game.graph.connected_nodes(lnwr)).to include(london)
    end

    it 'lets that RR run London - Lille - O30 over the ferry and through Lille' do
      pass_through!(cctc, lnwr, lille)
      train = game.trains.find { |t| t.name == '3' && !t.owner.is_a?(Engine::Corporation) }
      game.buy_train(lnwr, train, :free)
      route = explicit_route(train, london, lille, west)

      expect { game.check_connected(route, lnwr) }.not_to raise_error
      expect { route.revenue }.not_to raise_error
      expect(game.route_distance_str(route)).to eq('2')
    end

    it 'rejects the same run for a RR without a Lille token' do
      train = game.trains.find { |t| t.name == '3' && !t.owner.is_a?(Engine::Corporation) }
      game.buy_train(lnwr, train, :free)

      expect { explicit_route(train, london, lille, west).revenue }.to raise_error(Engine::GameError)
    end
  end

  describe 'Orient Express (§12)' do
    it 'still detects a run through a pass-through token on an Orient Express city' do
      lnwr = game.corporation_by_id('LNWR')
      origin = game.orient_express_origin_hexes.first.tile.cities.first
      destination = game.orient_express_destination_hexes.first.tile.cities.first
      allow(lnwr).to receive(:type).and_return(:major)
      pass_through!(cctc, lnwr, origin)
      route = instance_double(Engine::Route, corporation: lnwr, visited_stops: [origin, destination])

      expect(game.orient_express_run?(route)).to be(true)
    end
  end
end
