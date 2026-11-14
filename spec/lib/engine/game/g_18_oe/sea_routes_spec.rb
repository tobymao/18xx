# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'
require_relative 'route_helpers'

describe 'G18OE sea routes (§11.3.4, §11.3.6, §11.3.7, §11.3.8)' do
  include G18OESpecHelpers

  let(:game) { new_game }

  def path_at(hex_id, exit)
    game.hex_by_id(hex_id).tile.paths.find { |path| path.exits.include?(exit) }
  end

  describe 'sea traffic (§11.3.8)' do
    it 'paints every ferry with the one ferry colour' do
      colours = game.hexes.flat_map { |hex| hex.tile.paths }.filter_map(&:color).uniq
      expect(colours).to eq([Engine::Game::G18OE::Map::FERRY_TRACK_COLOR])
    end

    it 'treats ferry track and port sections as sea traffic, but not other land track in a sea zone' do
      expect(game.sea_traffic?(game.hex_by_id('N29').tile.paths.first)).to be(true)
      expect(game.sea_traffic?(path_at('M28', 5))).to be(true)
      expect(game.sea_traffic?(path_at('AF25', 3))).to be(true)
      expect(game.sea_traffic?(path_at('T87', 0))).to be(false)
      expect(game.sea_traffic?(path_at('I50', 1))).to be(false)
    end

    it 'does not count a dead-end arrow as a port exit' do
      expect(game.port_exit?('E28', 4)).to be(false)
      expect(game.port_exit?('H55', 4)).to be(true)
    end
  end

  describe 'port token reduction (§11.3.4)' do
    it 'reduces by one through Phase 6 and by two from Phase 7' do
      expect(game.port_token_reduction(double('phase', name: '2'))).to eq(1)
      expect(game.port_token_reduction(double('phase', name: '6'))).to eq(1)
      expect(game.port_token_reduction(double('phase', name: '7'))).to eq(2)
      expect(game.port_token_reduction(double('phase', name: '8'))).to eq(2)
    end
  end

  describe 'ferry links' do
    it 'lists the ferries at an exit and skips ferries to hexes missing from the map' do
      expect(game.ferry_links('I20', 4)).to contain_exactly([['J23', 2], 1], [['J25', 2], 1], [['I26', 1], 1])
      uk_fr = new_game(klass: Engine::Game::G18OEUKFR::Game)
      expect(uk_fr.ferry_links('M28', 5)).to eq([[['N31', 1], 0]])
    end
  end

  describe 'sea chains (§11.3.4, §11.3.6)' do
    include_context 'with 18OE route helpers'

    let(:dsj) { game.corporation_by_id('DSJ') }
    let(:bjv) { game.corporation_by_id('BJV') }

    it 'offers one crossing per usable port pair, cheapest first, with a JSON-safe id' do
      lay_code!('I50', 'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0')
      lay_code!('I52', 'city=revenue:20;path=a:0,b:_0;path=a:3,b:_0')
      token!('I52', dsj)
      chains = game.sea_chains(city('I50'), city('I52'), dsj)

      expect(chains.map { |c| c[:crossing].units }).to eq([1, 2])
      expect(chains.first[:id]).to eq(%w[crossing I50 5 I52 0])
      expect(chains.first[:paths]).to eq([])
      expect(chains.first[:nodes]).to eq([city('I50'), city('I52')])
      expect(chains.first[:crossing].hexes.map(&:id)).to eq(%w[J51 J51])
    end

    it 'needs track to an exit port but none to an offshore port (§11.3.6, PB 4.4)' do
      expect(game.sea_chains(city('I50'), city('C48'), dsj).map { |c| c[:id] }).to eq([%w[crossing I50 offshore C48 offshore]])
      expect(game.port_anchors(city('I50'), dsj)).to eq([['I50', :offshore]])
    end

    it 'uses a private port only with the corporation’s own token in its city (§11.3.6)' do
      lay_code!('I52', 'city=revenue:20;path=a:0,b:_0')
      expect(game.sea_chains(city('I50'), city('I52'), dsj)).to be_empty
      token!('I52', bjv)
      expect(game.sea_chains(city('I50'), city('I52'), dsj)).to be_empty
      expect(game.sea_chains(city('I50'), city('I52'), bjv).size).to eq(1)
    end

    it 'never crosses between two ports on one hex and returns nothing without a corporation' do
      lay_code!('I50', 'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0')
      expect(game.sea_chains(city('I50'), city('I50'), dsj)).to be_empty
      expect(game.sea_chains(city('I50'), city('C48'), nil)).to be_empty
    end

    it 'lets a crossing start or end at a red zone with printed track to its arrow (ruling 9)' do
      chains = game.sea_chains(city('I50'), offboard('N1'), dsj)
      expect(chains.map { |c| c[:crossing].units }).to eq([4])
    end

    it 'models Edinburgh–Bergen as a public pathless ferry of distance 1 (ruling 11)' do
      chains = game.sea_chains(city('B41'), city('G26'), dsj)
      expect(chains.size).to eq(1)
      expect(chains.first[:crossing].kind).to eq(:ferry)
      expect(chains.first[:crossing].units).to eq(1)
      expect(chains.first[:id]).to eq(%w[ferry B41 1 G26 offshore])
      expect(game.sea_chains(city('G26'), city('B41'), dsj).first[:crossing].kind).to eq(:ferry)
    end

    it 'builds on the UK-FR map without the missing hexes' do
      uk_fr = new_game(klass: Engine::Game::G18OEUKFR::Game)
      lnwr = uk_fr.corporation_by_id('LNWR')
      london = uk_fr.hex_by_id('M28').tile.cities.first
      lille = uk_fr.hex_by_id('N31').tile.cities.first
      southampton = uk_fr.hex_by_id('O28').tile.cities.first
      expect { uk_fr.sea_chains(london, lille, lnwr) }.not_to raise_error
      expect(uk_fr.port_marker_hex('I50', :offshore)).to be_nil
      expect(uk_fr.port_marker_hex('M28', :offshore)).to be_nil

      chains = uk_fr.sea_chains(london, southampton, lnwr)
      expect(chains.map { |c| c[:crossing].units }).to eq([1])
      expect(chains.first[:crossing].hexes.map(&:id)).to eq(%w[M28 O26])
    end

    it 'reads private port usability from tokens without building a sea network' do
      lay_code!('I52', 'city=revenue:20;path=a:0,b:_0')
      token!('I52', dsj)
      expect(game.graph).not_to receive(:sea_network)
      expect(game.port_usable?('I52', 0, dsj)).to be(true)
      expect(game.port_usable?('I52', 0, bjv)).to be(false)
      expect(game.port_usable?('E28', 4, dsj)).to be(false)
      expect(game.sea_chains(city('I50'), city('I52'), dsj).size).to eq(1)
    end
  end

  describe 'selecting, saving and rebuilding a crossing' do
    include_context 'with 18OE route helpers'

    let(:corp) { game.corporation_by_id('DSJ') }
    let(:four) { buy_train!('4') }

    before { baltic! }

    it 'offers the land connections first and then the crossings when a node is clicked (row 1)' do
      token!('I50', corp)
      token!('I52', corp)
      route = Engine::Route.new(game, game.phase, four, routes: [])

      expect(route.select(city('I50'), city('I52')).map { |c| c[:paths].empty? }).to eq([true])
      expect(route.select(city('I52'), town('H55')).map { |c| c[:paths].empty? }).to eq([false, true])
    end

    it 'extends the end that has a land link before attaching a crossing to either end (Review Focus 6)' do
      token!('I50', corp)
      token!('I52', corp)
      route = route_through(four, city('I52'), city('I50'), town('H55'))

      expect(node_sequence(route)).to eq([[city('I50'), city('I52')], [city('I52'), town('H55')]])
      expect(route.chains.map { |c| c[:paths].empty? }).to eq([true, false])
    end

    it 'has no sea chain to a private port without the corporation’s token (row 7)' do
      token!('I50', corp)
      route = Engine::Route.new(game, game.phase, four, routes: [])
      expect(route.select(city('I50'), city('I52'))).to be_empty
    end

    it 'round-trips a crossing from a pathless city through its saved form (row 8)' do
      bjv = game.corporation_by_id('BJV')
      token!('C48', bjv)
      train = game.trains.find { |t| t.name == '3' && !t.owner.is_a?(Engine::Corporation) }
      game.buy_train(bjv, train, :free)
      route = route_through(train, city('I50'), city('C48'))

      expect(route.connection_hexes).to eq(
        [{ 'from' => 'C48-0', 'hexes' => %w[crossing I50 offshore C48 offshore], 'to' => 'I50-0' }],
      )
      rebuilt = rebuild(route)
      expect(node_sequence(rebuilt)).to eq(node_sequence(route))
      expect(rebuilt.chains.first[:crossing].units).to eq(1)
    end

    it 'rebuilds to an empty route when the saved crossing’s private port token is gone (row 16)' do
      token!('I50', corp)
      token!('I52', corp)
      route = route_through(four, city('I50'), city('I52'))
      saved = route.connection_hexes
      city('I52').tokens.compact.each(&:remove!)
      game.graph.clear
      rebuilt = Engine::Route.new(game, game.phase, four, routes: [], connection_hexes: saved)

      expect(rebuilt.connection_data).to eq([])
    end

    it 'offers the Edinburgh–Bergen ferry chain (row 12a)' do
      route = Engine::Route.new(game, game.phase, four, routes: [])
      expect(route.select(city('B41'), city('G26')).map { |c| c[:crossing].kind }).to eq([:ferry])
    end
  end
end
