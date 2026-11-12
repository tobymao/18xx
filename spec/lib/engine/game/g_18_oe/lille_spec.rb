# frozen_string_literal: true

require 'spec_helper'
require 'engine/auto_router'
require_relative 'helpers'

describe 'G18OE Lille ferry passage (§11.2.2)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:corp) { game.corporation_by_id('LNWR') }
  let(:lille_hex) { game.hex_by_id('N31') }
  let(:lille) { lille_hex.tile.cities.first }
  let(:london) { game.hex_by_id('M28').tile.cities.first }
  let(:west) { game.hex_by_id('O30').tile.cities.first }

  def lay_tile!(hex_id, name, rotation)
    tile = game.tiles.find { |t| t.name == name && !t.hex }
    tile.rotate!(rotation)
    game.hex_by_id(hex_id).lay(tile)
    tile
  end

  def token!(city, corporation)
    city.place_token(corporation, corporation.next_token, free: true, check_tokenable: false)
  end

  def fill_lille!
    %w[PLM MZA].first(lille.normal_slots).each { |id| token!(lille, game.corporation_by_id(id)) }
    game.graph.clear
  end

  def reachable(hex_id)
    game.graph.reachable_hexes(corp)[game.hex_by_id(hex_id)]
  end

  def lille_path(edge)
    lille.paths.find { |path| path.exits == [edge] }
  end

  it 'places a WCF placeholder beyond the normal Lille positions at setup' do
    expect(lille.extra_tokens.map(&:type)).to eq([:neutral])
    expect(lille.extra_tokens.first.logo).to eq('/logos/18_oe/wcf_reserved.svg')
    expect(lille.tokens).to eq([nil])
  end

  it 'places the placeholder in Lille in the UK-FR scenario' do
    uk_fr = new_game(klass: Engine::Game::G18OEUKFR::Game)

    expect(uk_fr.wcf_placeholder).not_to be_nil
  end

  it 'blocks a full Lille to other RRs by the standard rules' do
    fill_lille!

    expect(lille.blocks?(corp)).to be(true)
  end

  it 'leaves the normal Lille positions free for other RRs' do
    expect(lille.available_slots).to eq(1)
    expect(lille.tokenable?(corp, free: true, tokens: corp.next_token)).to be(true)
  end

  it 'keeps the placeholder in the extra position through a Lille upgrade' do
    operator = start_regional!(game, 'LNWR', game.players.first)
    lay_tile!('O30', '57', 0)
    token!(west, operator)
    lay_tile!('N31', '201', 0)
    token!(lille, game.corporation_by_id('PLM'))
    game.phase.next! until game.phase.name == '3'
    round = enter_round!(game, game.operating_round(1))

    lay_first_legal!(game, round, 'N31')
    upgraded = lille_hex.tile.cities.first

    expect(upgraded.normal_slots).to eq(2)
    expect(upgraded.tokens.map { |t| t&.corporation&.id }).to eq(['PLM', nil])
    expect(upgraded.extra_tokens.map(&:type)).to eq([:neutral])
  end

  it 'keeps the WCF token in the extra position through a Lille upgrade' do
    lay_tile!('N31', '201', 0)
    token!(lille, game.corporation_by_id('PLM'))
    game.remove_wcf_placeholder!
    lille.place_token(corp, corp.next_token, free: true, check_tokenable: false, extra_slot: true)
    lay_tile!('N31', '208', 0)
    upgraded = lille_hex.tile.cities.first

    expect(upgraded.tokens.map { |t| t&.corporation&.id }).to eq(['PLM', nil])
    expect(upgraded.extra_tokens.map { |t| t.corporation.id }).to eq(['LNWR'])
  end

  context 'with a full Lille and a connected network' do
    before do
      lay_tile!('N31', 'OE33', 0)
      lay_tile!('O30', '57', 0)
      lay_tile!('O32', '9', 2)
      fill_lille!
    end

    it 'reaches London through the ferry but no other land side from the France side' do
      token!(west, corp)
      game.graph.clear

      expect(reachable('M28')).to be(true)
      expect(reachable('O32')).to be_nil
      expect(game.graph.connected_nodes(corp)).to include(london)
    end

    it 'passes from London through Lille onto every land side' do
      token!(london, corp)
      game.graph.clear

      expect(reachable('O30')).to be(true)
      expect(reachable('O32')).to be(true)
    end

    it 'is unrestricted while a normal Lille position is free' do
      token!(west, corp)
      lille.tokens.last.remove!
      game.graph.clear

      expect(reachable('O32')).to be(true)
    end

    it 'is unrestricted for a RR with a token in Lille' do
      token!(west, corp)
      lille.tokens.last.remove!
      token!(lille, corp)
      game.graph.clear

      expect(reachable('O32')).to be(true)
    end

    it 'follows standard blocking once the WCF token has replaced the placeholder' do
      token!(west, corp)
      game.remove_wcf_placeholder!
      wcf_owner = game.corporation_by_id('B')
      lille.place_token(wcf_owner, wcf_owner.next_token, free: true, check_tokenable: false, extra_slot: true)
      game.graph.clear

      expect(lille.extra_tokens.map(&:corporation)).to eq([wcf_owner])
      expect(lille.blocks?(corp)).to be(true)
      expect(reachable('N31')).to be(true)
      expect(reachable('M28')).to be_nil
      expect(reachable('O32')).to be_nil
    end

    describe 'routes' do
      def route_through(*paths)
        instance_double(Engine::Route, ordered_paths: paths)
      end

      it 'rejects entering and leaving Lille by land' do
        route = route_through(lille_path(0), lille_path(5))

        expect { game.check_connected(route, corp) }.to raise_error(Engine::GameError, 'Route is not connected')
      end

      it 'accepts entering Lille by the ferry and leaving by land' do
        route = route_through(lille_path(1), lille_path(5))

        expect { game.check_connected(route, corp) }.not_to raise_error
      end

      it 'accepts entering Lille by land and leaving by the ferry' do
        route = route_through(lille_path(5), lille_path(1))

        expect { game.check_connected(route, corp) }.not_to raise_error
      end

      it 'accepts land-in land-out while a normal Lille position is free' do
        lille.tokens.last.remove!
        route = route_through(lille_path(0), lille_path(5))

        expect { game.check_connected(route, corp) }.not_to raise_error
      end

      it 'rejects land-in land-out once the WCF token has replaced the placeholder' do
        game.remove_wcf_placeholder!
        route = route_through(lille_path(0), lille_path(5))

        expect { game.check_connected(route, corp) }.to raise_error(Engine::GameError, 'Route is not connected')
      end
    end
  end

  context 'with a second Channel crossing' do
    let(:p27_code) { 'path=a:4,b:1' }

    def lay_code!(hex_id, code)
      game.hex_by_id(hex_id).lay(Engine::Tile.from_code("X#{hex_id}", :yellow, code))
    end

    before do
      lay_tile!('N31', 'OE33', 0)
      lay_code!('O30', 'city=revenue:20;path=a:3,b:_0;path=a:0,b:_0')
      lay_code!('P29', 'path=a:3,b:1')
      lay_code!('P27', p27_code)
      lay_code!('P25', 'path=a:4,b:2')
      lay_code!('O24', 'town=revenue:10;path=a:5,b:_0;path=a:3,b:_0')
      lay_code!('M26', 'town=revenue:10;path=a:0,b:_0;path=a:4,b:_0')
      lay_code!('M28', 'city=revenue:30;path=a:1,b:_0;path=a:5,b:_0')
      lay_code!('O32', 'path=a:2,b:4')
      fill_lille!
      token!(west, corp)
      game.graph.clear
    end

    it 'passes from London through Lille onto its land sides after reaching Lille overland' do
      expect(reachable('M28')).to be(true)
      expect(reachable('O32')).to be(true)
    end

    context 'when the way back to London crosses a converging exit' do
      let(:p27_code) { 'path=a:4,b:1;path=a:0,b:1' }

      it 'still opens its land sides after reaching Lille overland' do
        expect(reachable('M28')).to be(true)
        expect(reachable('O32')).to be(true)
      end
    end
  end

  context 'with the auto-router' do
    let(:east) { game.hex_by_id('O32').tile.cities.first }
    let(:train) { game.trains.find { |t| t.name == '3' && !t.owner.is_a?(Engine::Corporation) } }

    before do
      lay_tile!('N31', 'OE33', 0)
      lay_tile!('O30', '57', 0)
      lay_tile!('O32', '57', 2)
      fill_lille!
      token!(west, corp)
      game.buy_train(corp, train, :free)
      game.graph.clear
    end

    it 'finds routes from the France side to London through the Lille ferry and none across Lille by land' do
      routes = Engine::AutoRouter.new(game).path([train], corp).first[train]
      stops = routes.map(&:visited_stops)

      expect(stops.any? { |s| [west, lille, london].all? { |node| s.include?(node) } }).to be(true)
      expect(stops.any? { |s| s.include?(west) && s.include?(east) }).to be(false)
    end

    it 'finds routes across Lille by land once a normal position is free' do
      lille.tokens.last.remove!
      game.graph.clear
      routes = Engine::AutoRouter.new(game).path([train], corp).first[train]

      expect(routes.any? { |route| route.visited_stops.include?(west) && route.visited_stops.include?(east) }).to be(true)
    end
  end
end
