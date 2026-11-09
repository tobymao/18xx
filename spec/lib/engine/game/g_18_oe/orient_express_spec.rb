# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE Orient Express (§12)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:president) { game.players[0] }
  let(:major) { start_major!(game, 'LNWR', president) }
  let(:regional) { start_regional!(game, 'KSS', president) }

  def city_at(hex_id, game: self.game)
    game.hex_by_id(hex_id).tile.cities.first
  end

  def phase_named(name)
    double('phase', name: name, tiles: [:yellow])
  end

  def train_for(entity, name, variant: nil, game: self.game)
    train = game.depot.upcoming.find { |t| t.name == name }
    game.buy_train(entity, train, :free)
    train.variant = variant if variant
    train
  end

  def route_for(train, stops, phase: phase_named('3'), game: self.game)
    route = Engine::Route.new(game, phase, train)
    allow(route).to receive(:visited_stops).and_return(stops)
    allow(route).to receive(:stops).and_return(stops)
    allow(route).to receive(:hexes).and_return(stops.map(&:hex))
    route
  end

  def route_set(*routes)
    routes.each { |route| route.routes = routes }
    routes
  end

  describe 'Orient Express hexes' do
    it 'looks up the destination and origin hexes by city name' do
      expect(game.orient_express_destination_hexes.map(&:id)).to contain_exactly('AA82', 'AB73')
      expect(game.orient_express_origin_hexes.map(&:id)).to contain_exactly(*%w[Q30 M28 M32 M50 Y14 C74 C70])
    end

    it 'omits offboard hexes from the origins' do
      expect(game.orient_express_origin_hexes.flat_map { |hex| hex.tile.offboards }).to be_empty
    end

    it 'uses only Paris and London as origins in UK-FR, leaving out the Berlin and Madrid offboards' do
      uk_fr = Engine::Game::G18OEUKFR::Game.new(%w[a b c])

      expect(Engine::Game::G18OEUKFR::Game::ORIENT_EXPRESS_ORIGINS).to eq(Engine::Game::G18OE::Game::ORIENT_EXPRESS_ORIGINS)
      expect(uk_fr.orient_express_origin_hexes.map(&:id)).to contain_exactly('Q30', 'M28')
      expect(uk_fr.orient_express_destination_hexes.map(&:id)).to contain_exactly('AA38')
    end
  end

  describe 'orient_express_reachable?' do
    let(:graph) { game.graph_for_entity(major) }

    def reach(*hex_ids)
      nodes = hex_ids.to_h { |hex_id| [city_at(hex_id), true] }
      allow(graph).to receive(:connected_nodes).with(major).and_return(nodes)
    end

    it 'is reachable when the network connects a destination and an origin' do
      reach('AA82', 'M50')

      expect(game.orient_express_reachable?(major)).to be(true)
    end

    it 'is not reachable with only the destination connected' do
      reach('AA82')

      expect(game.orient_express_reachable?(major)).to be(false)
    end

    it 'is not reachable with only an origin connected' do
      reach('M50')

      expect(game.orient_express_reachable?(major)).to be(false)
    end
  end

  describe 'orient_express_run?' do
    it 'is an Orient Express run when a major visits Constantinople and a metropolis' do
      route = route_for(train_for(major, '2+2'), [city_at('AA82'), city_at('M50')])

      expect(game.orient_express_run?(route)).to be(true)
    end

    it 'allows only majors to make an Orient Express run' do
      route = route_for(train_for(regional, '2+2'), [city_at('AA82'), city_at('M50')])

      expect(game.orient_express_run?(route)).to be(false)
    end

    it 'needs a metropolis as well as Constantinople' do
      route = route_for(train_for(major, '2+2'), [city_at('AA82'), city_at('N31')])

      expect(game.orient_express_run?(route)).to be(false)
    end
  end

  describe 'extra revenue' do
    let(:stops) { [city_at('AA82'), city_at('M50')] }

    it 'adds £30 in phase 3' do
      route = route_for(train_for(major, '2+2'), stops, phase: phase_named('3'))

      expect(game.revenue_for(route, route.stops)).to eq(20 + 30)
    end

    it 'adds £60 in phase 5' do
      route = route_for(train_for(major, '2+2'), stops, phase: phase_named('5'))

      expect(game.revenue_for(route, route.stops)).to eq(20 + 60)
    end

    it 'adds £100 in phase 7' do
      route = route_for(train_for(major, '2+2'), stops, phase: phase_named('7'))

      expect(game.revenue_for(route, route.stops)).to eq(20 + 100)
    end

    it 'does not double the extra revenue with a D train' do
      train = train_for(major, '7+7', variant: '4D')
      route = route_for(train, stops, phase: phase_named('7'))

      expect(game.revenue_for(route, route.stops)).to eq(40 + 100)
    end

    it 'gives a lone route the extra revenue' do
      route = route_for(train_for(major, '2+2'), stops, phase: phase_named('2'))

      expect(route.routes).to eq([])
      expect(game.revenue_for(route, route.stops)).to eq(20 + 30)
    end

    it 'gives no extra revenue to a regional' do
      route = route_for(train_for(regional, '2+2'), stops)

      expect(game.revenue_for(route, route.stops)).to eq(20)
    end
  end

  describe 'one Orient Express train per OR' do
    let(:first_train) { train_for(major, '2+2') }
    let(:second_train) { train_for(major, '2+2') }
    let(:route_a) { route_for(first_train, [city_at('AA82'), city_at('M50')]) }
    let(:route_b) { route_for(second_train, [city_at('AA82'), city_at('C74')]) }

    before do
      route_set(route_a, route_b)
      [route_a, route_b].each { |route| allow(route).to receive(:revenue) { game.revenue_for(route, route.stops) } }
    end

    it 'gives the extra revenue only to the first Orient Express route in the set' do
      expect(game.revenue_for(route_a, route_a.stops)).to eq(20 + 30)
      expect(game.revenue_for(route_b, route_b.stops)).to eq(40)
    end

    it 'labels only that route as the Orient Express' do
      expect(game.revenue_str(route_a)).to end_with(' + Orient Express')
      expect(game.revenue_str(route_b)).not_to end_with(' + Orient Express')
    end

    it 'reports the best Orient Express train revenue including the extra revenue' do
      expect(game.orient_express_train_revenue([route_a, route_b])).to eq(40 + 30)
    end

    it 'has no Orient Express train revenue without an Orient Express route' do
      plain = route_for(train_for(major, '2+2'), [city_at('AA82'), city_at('N31')])
      allow(plain).to receive(:revenue) { game.revenue_for(plain, plain.stops) }

      expect(game.orient_express_train_revenue([plain])).to be_nil
    end

    it 'chooses each route\'s stops without recursing through the Orient Express comparison' do
      visits = { route_a => [city_at('AA82'), city_at('M50')], route_b => [city_at('AA82'), city_at('C74')] }
      visits.each do |route, stops|
        allow(route).to receive(:stops).and_call_original
        allow(route).to receive(:visited_stops).and_return(stops)
        allow(route.train).to receive(:requires_token).and_return(false)
      end
      allow(game).to receive(:revenue_stops) { |route| visits[route] }

      expect(route_b.stops).to eq(visits[route_b])
      expect(game.revenue_for(route_a, route_a.stops)).to eq(20 + 30)
    end
  end

  describe 'combining non-permanent trains (§12.1)' do
    let(:help_text) do
      '2+2, 3 and 4 trains may be combined into one train to make an Orient Express run. '\
        'A combined train must run an Orient Express route; use Undo to cancel a combination.'
    end
    let(:step_receivership_help) do
      "#{major.name} is in receivership (it has no president). Most of its actions are automated, "\
        "but it must have a player manually run its trains. Please enter the best route you see for #{major.name}."
    end
    let(:round) do
      major
      enter_round!(game, game.operating_round(1))
    end
    let(:step) { round_step(round, Engine::Game::G18OE::Step::Route) }
    let(:dividend) { round_step(round, Engine::Game::G18OE::Step::Dividend) }
    let(:first_two) { train_for(major, '2+2') }
    let(:three) { train_for(major, '3') }
    let(:second_two) { train_for(major, '2+2') }

    before do
      allow(game).to receive(:can_run_route?).and_return(true)
      allow(step).to receive(:current_entity).and_return(major)
    end

    def combine!(*trains)
      step.process_double_head_trains(Engine::Action::DoubleHeadTrains.new(major, trains: trains))
      major.trains.find { |train| game.combined_train?(train) }
    end

    it 'offers combining to a major with two or more non-permanent trains that can reach an Orient Express run' do
      allow(game).to receive(:orient_express_reachable?).with(major).and_return(true)
      first_two
      three
      second_two

      expect(step.actions(major)).to include('run_routes', 'double_head_trains')
    end

    it 'does not offer combining when the network cannot reach an Orient Express run' do
      allow(game).to receive(:orient_express_reachable?).with(major).and_return(false)
      first_two
      three
      second_two

      expect(step.actions(major)).to eq(%w[run_routes])
    end

    it 'offers combining without checking the network while loading' do
      allow(game).to receive(:loading).and_return(true)
      allow(game).to receive(:orient_express_reachable?).and_return(false)
      first_two
      three
      second_two

      expect(step.actions(major)).to include('double_head_trains')
      expect(game).not_to have_received(:orient_express_reachable?)
    end

    it 'does not offer combining to a major with a single non-permanent train' do
      first_two

      expect(step.actions(major)).to eq(%w[run_routes])
    end

    it 'does not offer combining to a regional' do
      allow(step).to receive(:current_entity).and_return(regional)
      train_for(regional, '2+2')
      train_for(regional, '2+2')

      expect(step.actions(regional)).to eq(%w[run_routes])
    end

    it 'does not let a permanent train be combined' do
      train_for(major, '5')
      first_two

      expect(game.double_head_candidates(major)).to eq([first_two])
    end

    it 'combines a 2+2, 3 and 2+2 into one 7+4 train' do
      combined = combine!(first_two, three, second_two)

      expect(combined.name).to eq('7+4')
      expect(combined.distance).to eq([{ 'nodes' => ['town'], 'pay' => 4, 'visit' => 99 },
                                       { 'nodes' => %w[city offboard town], 'pay' => 7, 'visit' => 7 }])
      expect(combined.owner).to eq(major)
    end

    it 'stops the component trains running on their own' do
      combined = combine!(first_two, three, second_two)

      expect([first_two, three, second_two].map(&:operated)).to eq([true, true, true])
      expect(game.route_trains(major)).to eq([combined])
      expect(round.combined_trains[combined]).to eq([first_two, three, second_two])
    end

    it 'logs the combination' do
      combine!(first_two, three, second_two)

      expect(game.log.last.message).to eq("#{major.name} combines 2+2, 2+2, 3 into a 7+4 train for the Orient Express")
    end

    it 'rejects combining a non-permanent train with a permanent one' do
      five = train_for(major, '5')
      three

      expect { combine!(three, five) }.to raise_error(Engine::GameError)
    end

    it 'allows only one combination per operating round' do
      trains = Array.new(4) { train_for(major, '2+2') }

      combine!(trains[0], trains[1])

      expect(game.double_head_candidates(major)).to be_empty
      expect(step.actions(major)).to eq(%w[run_routes])
    end

    it 'keeps combined trains out of the train info list' do
      expect(combine!(first_two, three, second_two).reserved).to be(true)
    end

    it 'rejects combining fewer than two trains' do
      expect { combine!(first_two) }.to raise_error(Engine::GameError)
    end

    it 'finds the combined train again by id' do
      combined = combine!(first_two, three, second_two)

      expect(game.train_by_id(combined.id)).to equal(combined)
    end

    it 'allows a combined train to run only an Orient Express route' do
      combined = combine!(first_two, three, second_two)
      plain = route_for(combined, [city_at('AA82'), city_at('N31')])
      orient_express = route_for(combined, [city_at('AA82'), city_at('M50')])

      expect { game.check_other(plain) }.to raise_error(Engine::GameError, 'Combined trains may only run an Orient Express route')
      expect { game.check_other(orient_express) }.not_to raise_error
    end

    it 'clears the combined trains and Orient Express revenue for the next company' do
      combine!(first_two, three, second_two)
      round.orient_express_revenue = 50

      step.setup

      expect(round.combined_trains).to eq({})
      expect(round.orient_express_revenue).to be_nil
    end

    it 'records the Orient Express train revenue when the routes are run' do
      route = route_for(train_for(major, '2+2'), [city_at('AA82'), city_at('M50')], phase: phase_named('2'))
      allow(route).to receive(:revenue) { game.revenue_for(route, route.stops) }

      step.process_run_routes(Engine::Action::RunRoutes.new(major, routes: [route]))

      expect(round.orient_express_revenue).to eq(50)
    end

    it 'records no Orient Express revenue when no route is an Orient Express run' do
      route = route_for(train_for(major, '2+2'), [city_at('AA82'), city_at('N31')], phase: phase_named('2'))
      allow(route).to receive(:revenue) { game.revenue_for(route, route.stops) }

      step.process_run_routes(Engine::Action::RunRoutes.new(major, routes: [route]))

      expect(round.orient_express_revenue).to be_nil
    end

    def run_combined!(combined, stops)
      route = route_for(combined, stops, phase: phase_named('2'))
      allow(route).to receive(:revenue) { game.revenue_for(route, route.stops) }
      step.process_run_routes(Engine::Action::RunRoutes.new(major, routes: [route]))
    end

    it 'removes the combined train from the corporation when the routes run' do
      combined = combine!(first_two, three, second_two)

      run_combined!(combined, [city_at('AA82'), city_at('M50')])

      expect(major.trains).not_to include(combined)
      expect(combined.owner).to be_nil
      expect(major.trains).to contain_exactly(first_two, three, second_two)
      expect([first_two, three, second_two].map(&:operated)).to eq([true, true, true])
      expect(round.orient_express_revenue).to eq(20 + 30)
    end

    it 'removes the combined train even when it runs no route' do
      combined = combine!(first_two, three, second_two)

      step.process_run_routes(Engine::Action::RunRoutes.new(major, routes: []))

      expect(major.trains).not_to include(combined)
      expect(combined.owner).to be_nil
      expect(round.orient_express_revenue).to be_nil
    end

    it 'reuses a previous combination of the same trains' do
      combined = combine!(first_two, three, second_two)
      run_combined!(combined, [city_at('AA82'), city_at('M50')])
      [first_two, three, second_two].each { |train| train.operated = false }

      again = combine!(first_two, three, second_two)

      expect(again).to equal(combined)
      expect(again.rusted).to be(false)
      expect(again.operated).to be(false)
      expect(again.owner).to eq(major)
    end

    it 'explains combining to a major while non-permanent trains remain' do
      first_two
      three
      second_two

      expect(step.help).to eq([help_text])
    end

    it 'puts the receivership help before the combining help' do
      allow(major).to receive(:receivership?).and_return(true)

      expect(step.help).to eq([step_receivership_help, help_text])
    end

    it 'adds no combining help for a regional' do
      allow(step).to receive(:current_entity).and_return(regional)

      expect(step.help).to eq('')
    end

    it 'adds no combining help once every non-permanent train has rusted' do
      game.depot.trains.each { |train| train.rusted = true if train.rusts_on }

      expect(step.help).to eq('')
    end
  end

  describe 'first-time bonus (§12.2)' do
    let(:round) do
      major
      enter_round!(game, game.operating_round(1))
    end
    let(:bonus) { round_step(round, Engine::Game::G18OE::Step::OrientExpressBonus) }
    let(:dividend) { round_step(round, Engine::Game::G18OE::Step::Dividend) }

    before do
      allow(bonus).to receive(:current_entity).and_return(major)
      round.orient_express_revenue = 50
      game.stock_market.move(major, cell(game, 75).coordinates)
    end

    def choose!(choice)
      bonus.process_choose(Engine::Action::Choose.new(major, choice: choice))
    end

    it 'follows the dividend step' do
      steps = game.operating_round(1).steps

      expect(steps[steps.index { |s| s.is_a?(Engine::Game::G18OE::Step::Dividend) } + 1])
        .to be_a(Engine::Game::G18OE::Step::OrientExpressBonus)
    end

    it 'offers the choice after an Orient Express run' do
      expect(bonus.actions(major)).to eq(%w[choose])
      expect(bonus.choice_name).to eq('Orient Express first-time bonus')
      expect(bonus.choices.keys).to eq(%w[cash right])
      expect(bonus.choices['cash']).to include(game.format_currency(50))
      expect(bonus.choices['right']).to eq('Share value RIGHT 3 times')
    end

    it 'offers nothing without an Orient Express run' do
      round.orient_express_revenue = nil

      expect(bonus.actions(major)).to eq([])
    end

    it 'offers nothing once the major has the marker' do
      game.place_orient_express_marker!(major)

      expect(bonus.actions(major)).to eq([])
    end

    it 'pays the Orient Express train revenue from the bank and places the marker' do
      before_cash = major.cash

      choose!('cash')

      expect(major.cash).to eq(before_cash + 50)
      expect(game.orient_express_marker?(major)).to be(true)
      expect(game.status_array(major)).to eq([['Orient Express marker']])
    end

    it 'moves the share price RIGHT three times and places the marker' do
      before_cash = major.cash
      row, column = cell(game, 75).coordinates
      expected = game.stock_market.market[row][column + 3]

      choose!('right')

      expect(major.share_price).to equal(expected)
      expect(major.cash).to eq(before_cash)
      expect(game.orient_express_marker?(major)).to be(true)
    end

    it 'rejects a choice that is not offered' do
      expect { choose!('nonsense') }.to raise_error(Engine::GameError)
    end

    it 'shows no marker status for a major without one' do
      expect(game.status_array(major)).to be_nil
    end
  end

  describe 'UK/France' do
    let(:uk_fr) { new_game(klass: Engine::Game::G18OEUKFR::Game) }
    let(:uk_fr_major) { start_major!(uk_fr, 'LNWR', uk_fr.players[0]) }

    it 'treats a run between Paris and Constantinople as an Orient Express run (PB 6.1.5)' do
      train = train_for(uk_fr_major, '2+2', game: uk_fr)
      route = route_for(train, [city_at('Q30', game: uk_fr), uk_fr.hex_by_id('AA38').tile.offboards.first], game: uk_fr)

      expect(uk_fr.orient_express_run?(route)).to be(true)
    end
  end
end
