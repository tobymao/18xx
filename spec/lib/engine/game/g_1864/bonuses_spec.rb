# frozen_string_literal: true

require 'spec_helper'

describe 'G1864 route bonuses' do
  let(:game) { Engine::Game::G1864::Game.new(%w[alice bob carol], seed: 1) }
  let(:corporation) { game.corporations.first }

  def fake_stop(hex, revenue)
    groups = (hex.tile.offboards + hex.tile.cities + hex.tile.towns).flat_map(&:groups)
    double("stop_#{hex.id}", hex: hex, route_revenue: revenue, groups: groups)
  end

  def fake_route(hexes, train)
    instance_double(Engine::Route, corporation: corporation, phase: game.phase, train: train, hexes: hexes)
  end

  it 'defines the three $80 east-west bonuses and the Forty-Niner route' do
    expect(Engine::Game::G1864::Game::EAST_WEST_BONUSES).to contain_exactly(
      [['Great Lakes'], ['Seattle']],
      [['New Orleans'], ['Los Angeles']],
      [['St. Louis', 'Chicago'], ['San Francisco']]
    )
    expect(Engine::Game::G1864::Game::FORTY_NINER_ROUTE)
      .to eq(['Chicago', 'Omaha', 'Cheyenne', 'Salt Lake', 'San Francisco'])
  end

  it 'treats Canada and the Great Lakes as N, and Mexico and New Orleans as S' do
    expect(Engine::Game::G1864::Game::NORTH_GROUPS).to contain_exactly('Canada', 'GreatLakes')
    expect(Engine::Game::G1864::Game::SOUTH_GROUPS).to contain_exactly('Mexico', 'NewOrleans')
  end

  describe 'over the real map' do
    let(:chicago) { game.hex_by_id('E28') }
    let(:san_francisco) { game.hex_by_id('G2') }
    let(:omaha) { game.hex_by_id('F27') }
    let(:cheyenne) { game.hex_by_id('F19') }
    let(:salt_lake) { game.hex_by_id('G14') }
    let(:great_lakes) { game.hex_by_id('B27') }
    let(:seattle) { game.hex_by_id('B5') }
    let(:north_hex) { game.hex_by_id('A16') }
    let(:south_hex) { game.hex_by_id('K28') }
    let(:plain_train) { double('train', multiplier: nil) }
    let(:multiplier_train) { double('train', multiplier: 2) }

    it 'pays the $80 Chicago/San Francisco pair bonus for a route touching both' do
      stops = [fake_stop(chicago, 30), fake_stop(san_francisco, 40)]
      route = fake_route([chicago, san_francisco], plain_train)

      expect(game.revenue_for(route, stops)).to eq(30 + 40 + 80)
    end

    it 'does not pay the pair bonus for a route missing one half of the pair' do
      stops = [fake_stop(chicago, 30)]
      route = fake_route([chicago], plain_train)

      expect(game.revenue_for(route, stops)).to eq(30)
    end

    it 'pays the St. Louis or Chicago/San Francisco bonus once for a route touching all three' do
      st_louis = game.hex_by_id('H29')
      stops = [fake_stop(st_louis, 20), fake_stop(chicago, 30), fake_stop(san_francisco, 40)]
      route = fake_route([st_louis, chicago, san_francisco], plain_train)

      expect(game.revenue_for(route, stops)).to eq(20 + 30 + 40 + 80)
    end

    it 'does not double the pair bonus for a 2+2/5+5E multiplier train' do
      stops = [fake_stop(chicago, 30), fake_stop(san_francisco, 40)]

      plain_revenue = game.revenue_for(fake_route([chicago, san_francisco], plain_train), stops)
      multiplier_revenue = game.revenue_for(fake_route([chicago, san_francisco], multiplier_train), stops)

      expect(multiplier_revenue).to eq(plain_revenue)
      expect(multiplier_revenue).to eq(70 + 80)
    end

    it 'pays the $80 Great Lakes/Seattle pair bonus' do
      stops = [fake_stop(great_lakes, 20), fake_stop(seattle, 20)]
      route = fake_route([great_lakes, seattle], plain_train)

      expect(game.revenue_for(route, stops)).to eq(20 + 20 + 80)
    end

    it 'pays the $80 north/south marker bonus for a route touching both marker hexes' do
      stops = [fake_stop(north_hex, 20), fake_stop(south_hex, 20)]
      route = fake_route([north_hex, south_hex], plain_train)

      expect(game.revenue_for(route, stops)).to eq(20 + 20 + 80)
    end

    it 'pays the north/south bonus through any hex of the Canada and Mexico offboards' do
      canada = game.hex_by_id('A12')
      mexico = game.hex_by_id('L9')
      stops = [fake_stop(canada, 20), fake_stop(mexico, 20)]
      route = fake_route([canada, mexico], plain_train)

      expect(game.revenue_for(route, stops)).to eq(20 + 20 + 80)
    end

    it 'does not pay the north/south bonus for a route touching only one marker side' do
      stops = [fake_stop(north_hex, 20), fake_stop(chicago, 30)]
      route = fake_route([north_hex, chicago], plain_train)

      expect(game.revenue_for(route, stops)).to eq(20 + 30)
    end

    it 'pays the $120 Forty-Niner Route bonus for a route through all five cities' do
      stops = [
        fake_stop(chicago, 20),
        fake_stop(omaha, 20),
        fake_stop(cheyenne, 20),
        fake_stop(salt_lake, 20),
        fake_stop(san_francisco, 20),
      ]
      route = fake_route([chicago, omaha, cheyenne, salt_lake, san_francisco], plain_train)

      expect(game.revenue_for(route, stops)).to eq(100 + 120 + 80)
    end

    it 'does not pay the Forty-Niner bonus for a route missing one city' do
      stops = [
        fake_stop(chicago, 20),
        fake_stop(omaha, 20),
        fake_stop(cheyenne, 20),
        fake_stop(salt_lake, 20),
      ]
      route = fake_route([chicago, omaha, cheyenne, salt_lake], plain_train)

      expect(game.revenue_for(route, stops)).to eq(80)
    end

    it 'still applies the Local Contract bonus exactly once alongside route bonuses' do
      company = game.companies.find { |c| c.name == 'Local Contract' }
      minor = company.owner
      home_hex = game.hex_by_id(minor.coordinates)
      token = minor.tokens.first
      token.used = true
      token.city = home_hex.tile.cities.first
      token.hex = home_hex

      home_city = home_hex.tile.cities.first
      game.place_local_contract!(company, home_city)
      allow(home_city).to receive(:route_revenue).and_return(30)

      stops = [home_city, fake_stop(chicago, 30)]
      route = instance_double(Engine::Route, corporation: minor, phase: game.phase, train: plain_train,
                                             hexes: [home_hex, chicago])

      expect(game.revenue_for(route, stops)).to eq(30 + 30 + 10)
    end

    it 'doubles the Local Contract bonus for a 2+2/5+5E multiplier train' do
      company = game.companies.find { |c| c.name == 'Local Contract' }
      minor = company.owner
      home_hex = game.hex_by_id(minor.coordinates)
      home_city = home_hex.tile.cities.first
      game.place_local_contract!(company, home_city)
      allow(home_city).to receive(:route_revenue).and_return(60)

      stops = [home_city, fake_stop(chicago, 60)]
      route = instance_double(Engine::Route, corporation: minor, phase: game.phase, train: multiplier_train,
                                             hexes: [home_hex, chicago])

      expect(game.revenue_for(route, stops)).to eq(60 + 60 + 20)
    end
  end
end
