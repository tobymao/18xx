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

  describe 'port token distance (§11.3.4)' do
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

  describe 'city limit (§11.3.3, §11.3.4, §11.3.7)' do
    include_context 'with 18OE route helpers'

    let(:corp) { game.corporation_by_id('DSJ') }
    let(:four) { buy_train!('4') }
    let(:three) { buy_train!('3') }
    let(:two_plus_two) { buy_train!('2+2') }

    def phase_named(name) = double('phase', name: name, tiles: %i[yellow green])

    before { baltic! }

    it 'counts every sea zone against the city limit and shows it in the distance (rows 2, 10)' do
      token!('J63', corp)
      route = explicit_route(four, city('I50'), town('K60'), city('J63'))

      expect(route.chains.first[:crossing].units).to eq(2)
      expect(game.sea_cost(route)).to eq(2)
      expect(route.distance_str).to eq('2 + 2 sea')
      expect(route.revenue).to eq(60)
      expect { explicit_route(two_plus_two, city('I50'), town('K60'), city('J63')).revenue }.to raise_error(Engine::RouteTooLong)
    end

    it 'cancels the crossing with the København and Malmö tokens and charges the ferry (PB 4.5, row 3)' do
      token!('I50', corp)
      token!('I52', corp)
      route = route_through(four, city('I50'), city('I52'), town('H55'), town('K60'), city('J63'))

      expect(game.sea_cost(route)).to eq(1)
      expect(route.distance_str).to eq('3 + 1 sea')
      expect(route.revenue).to eq(80)
      expect { route_through(three, city('I50'), city('I52'), town('H55'), town('K60'), city('J63')).revenue }
        .to raise_error(Engine::RouteTooLong)
    end

    it 'applies a token at the far port of the crossing (row 4)' do
      token!('J63', corp)
      route = explicit_route(three, town('H55'), city('J63'))

      expect(route.chains.first[:crossing].units).to eq(1)
      expect(game.sea_cost(route)).to eq(0)
    end

    it 'reduces by two from Phase 7 (row 5)' do
      token!('I50', corp)
      six = Engine::Route.new(game, phase_named('6'), four, routes: [])
      seven = Engine::Route.new(game, phase_named('7'), four, routes: [])
      [six, seven].each { |route| route.routes = [route] }
      [six, seven].each do |route|
        route.connection_data << route.segment(route.select(city('I50'), town('K60')).first, left: city('I50'))
      end

      expect(game.sea_cost(six)).to eq(1)
      expect(game.sea_cost(seven)).to eq(0)
    end

    it 'uses each port token once per train and picks the cheapest assignment (PB 4.5 J minor, row 6)' do
      j = game.corporation_by_id('J')
      lay_code!('AA20', 'city=revenue:30;path=a:5,b:_0')
      lay_code!('AB27', 'city=revenue:20;path=a:1,b:_0;path=a:0,b:_0')
      token!('AA20', j)
      train = game.trains.find { |t| t.name == '3' && !t.owner.is_a?(Engine::Corporation) }
      game.buy_train(j, train, :free)
      route = explicit_route(train, offboard('AF25'), city('AA20'), city('AB27'))

      expect(node_sequence(route)).to eq([[offboard('AF25'), city('AA20')], [city('AA20'), city('AB27')]])
      expect(game.sea_legs(route).map(&:units)).to eq([1, 1])
      expect(game.sea_cost(route)).to eq(1)
      token!('AB27', j)
      expect(game.sea_cost(explicit_route(train, offboard('AF25'), city('AA20'), city('AB27')))).to eq(0)
    end

    it 'counts only a port token the train runs through (§11.3.4)' do
      lay_code!('M28', 'city=revenue:40;city=revenue:40;path=a:5,b:_0;path=a:2,b:_1')
      london_west, london_east = game.hex_by_id('M28').tile.cities
      london_east.place_token(corp, Engine::Token.new(corp), free: true, check_tokenable: false)
      game.graph.clear
      route = explicit_route(four, london_west, city('C48'))

      expect(route.chains.first[:crossing].units).to eq(3)
      expect(game.sea_cost(route)).to eq(3)
    end

    it 'charges a ferry its full distance once, towns holding no tokens (row 12)' do
      expect(game.sea_cost(explicit_route(two_plus_two, town('H55'), town('K60')))).to eq(1)
      expect(game.sea_cost(explicit_route(three, city('AE72'), town('AE74')))).to eq(1)
      expect(game.sea_cost(explicit_route(three, city('AE72'), town('AE74'), city('AD79')))).to eq(1)
      expect(game.sea_cost(explicit_route(three, town('AE74'), city('AD79')))).to eq(1)
    end

    it 'charges the Edinburgh–Bergen ferry one unit (row 12a)' do
      expect(game.sea_cost(explicit_route(three, city('B41'), city('G26')))).to eq(1)
    end

    it 'reaches New York from København with a 5 train (row 12b)' do
      token!('I50', corp)
      route = explicit_route(buy_train!('5'), city('I50'), offboard('N1'))

      expect(route.distance_str).to eq('2 + 3 sea')
      expect { route.revenue }.not_to raise_error
    end

    it 'reduces the city row of a 4D train (Review Focus 3)' do
      token!('J63', corp)
      four_d = game.trains.find { |t| t.name == '7+7' }
      four_d.variant = '4D'
      four_d.owner = corp
      route = explicit_route(four_d, city('I50'), town('K60'), city('J63'))

      expect(game.route_train_distance(route, four_d).find { |row| row['nodes'].include?('city') }['visit']).to eq(2)
      expect(route.visited_stops).to include(town('K60'))
      expect(route.stops).not_to include(town('K60'))
    end

    it 'costs nothing for a train without an owner (Review Focus 4)' do
      train = game.trains.find { |t| t.name == '3' && !t.owner.is_a?(Engine::Corporation) }
      route = Engine::Route.new(game, game.phase, train, routes: [])

      expect(game.sea_cost(route)).to eq(0)
      expect(game.route_distance_str(route)).to eq('0')
    end
  end

  describe 'connection and legality (§11.3.4, §11.3.6, §11.3.7)' do
    include_context 'with 18OE route helpers'

    let(:corp) { game.corporation_by_id('DSJ') }
    let(:four) { buy_train!('4') }
    let(:three) { buy_train!('3') }

    before { baltic! }

    it 'runs to a full foreign city by sea but not through it (row 9)' do
      lay_code!('H21', 'city=revenue:20;path=a:4,b:_0;path=a:1,b:_0')
      lay_code!('H19', 'town=revenue:10;path=a:4,b:_0')
      gswr = game.corporation_by_id('GSWR')
      token!('I20', gswr)
      token!('H21', game.corporation_by_id('BJV'))
      game.buy_train(gswr, three, :free)

      expect { game.check_connected(explicit_route(three, city('I20'), city('H21')), gswr) }.not_to raise_error
      expect { game.check_connected(explicit_route(three, city('I20'), city('H21'), town('H19')), gswr) }
        .to raise_error(Engine::GameError, 'Route is not connected')
    end

    it 'requires a land hex side between two crossings (row 10)' do
      token!('I50', corp)
      lay_code!('D41', 'town=revenue:10;path=a:0,b:_0;path=a:3,b:_0')

      expect { game.check_other(explicit_route(four, city('I50'), city('C48'), town('D41'))) }
        .to raise_error(Engine::GameError, /land hex side/)
      expect { game.check_other(explicit_route(four, city('C48'), city('I50'), town('K60'))) }
        .to raise_error(Engine::GameError)

      lay_code!('I50', 'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0')
      in_offshore_out_exit = explicit_route(four, city('C48'), city('I50'), town('K60'))
      expect(in_offshore_out_exit.chains.map { |c| c[:crossing].from[1] }).to eq([:offshore, 5])
      expect { game.check_other(in_offshore_out_exit) }.to raise_error(Engine::GameError)
    end

    it 'lets a ferry follow an offshore landing on the same hex (row 11)' do
      lnwr = game.corporation_by_id('LNWR')
      token!('M28', lnwr)
      train = game.trains.find { |t| t.name == '5' && !t.owner.is_a?(Engine::Corporation) }
      game.buy_train(lnwr, train, :free)
      route = explicit_route(train, city('N31'), city('M28'), city('C48'))

      expect { game.check_other(route) }.not_to raise_error
      expect(game.sea_cost(route)).to eq(2)
    end

    it 'exempts the Edinburgh–Bergen ferry from the land hex side rule (row 12a)' do
      lay_code!('D41', 'town=revenue:10;path=a:0,b:_0;path=a:3,b:_0')
      token!('G26', corp)
      route = explicit_route(four, town('D41'), city('B41'))
      ferry = route.select(city('B41'), city('G26')).find { |c| c[:crossing]&.kind == :ferry }
      route.connection_data << route.segment(ferry, left: city('B41'))
      route.connection_data << route.segment(route.select(city('G26'), city('C48')).first, left: city('G26'))

      expect(route.chains.map { |c| c[:crossing].kind }).to eq(%i[crossing ferry crossing])
      expect { game.check_other(route) }.not_to raise_error
    end
  end

  describe 'shared sea traffic (§11.3.8)' do
    include_context 'with 18OE route helpers'

    let(:corp) { game.corporation_by_id('DSJ') }
    let(:four) { buy_train!('4') }
    let(:three) { buy_train!('3') }

    before do
      baltic!
      token!('I50', corp)
      token!('I52', corp)
    end

    def pair(first, second)
      first.routes = second.routes = [first, second]
      [first, second]
    end

    def shared_pair(from, to)
      pair(explicit_route(four, from, to), explicit_route(three, from, to))
    end

    it 'lets two trains make the same crossing and ride the same ferry, but not reuse land track (row 13)' do
      expect { game.check_overlap(shared_pair(city('I50'), city('I52'))) }.not_to raise_error
      expect { game.check_overlap(shared_pair(town('H55'), town('K60'))) }.not_to raise_error
      expect { game.check_overlap(shared_pair(city('I52'), town('H55'))) }.to raise_error(Engine::GameError, /reuse track/)
    end

    it 'still offers the ferry to a second train (row 14)' do
      first = explicit_route(four, town('H55'), town('K60'))
      second = Engine::Route.new(game, game.phase, three, routes: [])
      first.routes = second.routes = [first, second]

      expect(second.select(town('H55'), town('K60')).map { |c| c[:paths].empty? }).to eq([false, true])
    end
  end

  describe 'route step help' do
    include_context 'with 18OE route helpers'

    let(:corp) { game.corporation_by_id('DSJ') }
    let(:step) { Engine::Game::G18OE::Step::Route.new(game, game.round) }

    before { allow(step).to receive(:current_entity).and_return(corp) }

    it 'explains sea crossings only when the corporation can reach the sea' do
      expect(Array(step.help).join).not_to include('across the sea')
      token!('I50', corp)
      expect(Array(step.help).join).to include('Click a city or town across the sea to add a crossing')
    end
  end

  describe 'sea crossing map data' do
    let(:crossing) do
      game.sea_crossing(:crossing, ['I50', 5], ['D41', 0],
                        [game.hex_by_id('I50').tile.cities.first, game.hex_by_id('D41').tile.towns.first])
    end

    it 'tells sea hexes from land hexes' do
      expect(crossing.sea_hex?(game.hex_by_id('H49'))).to be(true)
      expect(crossing.sea_hex?(game.hex_by_id('I50'))).to be(false)
    end

    it 'prices a line stepping over land where two seas meet only at a channel passage' do
      expect(crossing.channel_passage_cost).to eq(20)
    end
  end
end
