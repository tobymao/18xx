# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE Minor L +1+1 marker (§15.11)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:player) { game.players.first }
  let(:minor_l) { start_minor!(game, 'L', player, 'RU') }
  let(:major) { start_major!(game, 'LNWR', player) }
  let(:round) do
    major
    enter_round!(game, game.operating_round(1))
  end
  let(:step) { round_step(round, Engine::Game::G18OE::Step::Route) }

  def card(name)
    game.depot.upcoming.find { |t| t.name == name }
  end

  def give!(corporation, train)
    game.buy_train(corporation, train, :free)
    train
  end

  def combine!(*trains)
    step.process_double_head_trains(Engine::Action::DoubleHeadTrains.new(major, trains: trains))
    major.trains.find { |train| game.combined_train?(train) }
  end

  def mark!(train, entity = major)
    step.process_choose(Engine::Action::Choose.new(entity, choice: "one_plus_one_marker:#{train.id}"))
  end

  before do
    allow(game).to receive(:can_run_route?).and_return(true)
    allow(game).to receive(:sea_connectivityable?).and_return(false)
    allow(step).to receive(:current_entity).and_return(major)
  end

  context 'when the RR holds the marker' do
    before { game.add_minor_charter!(minor_l, major) }

    it "offers the RR's runnable trains for the marker" do
      two = give!(major, card('2+2'))
      three = give!(major, card('3'))

      expect(step.actions(major)).to include('choose')
      expect(step.choices).to eq(
        "one_plus_one_marker:#{two.id}" => '+1+1 marker on 2+2 train',
        "one_plus_one_marker:#{three.id}" => '+1+1 marker on 3 train',
      )
      expect(step.choice_name).to eq('Attach to a train')
    end

    it 'moves the marker when another train is chosen' do
      two = give!(major, card('2+2'))
      three = give!(major, card('3'))
      mark!(two)
      mark!(three)

      expect(game.add_on_train?(:one_plus_one_marker, three)).to be(true)
      expect(game.add_on_train?(:one_plus_one_marker, two)).to be(false)
      expect(step.choices.keys).to eq(["one_plus_one_marker:#{two.id}"])
    end

    it 'resets the marker each OR' do
      mark!(give!(major, card('3')))
      step.setup

      expect(round.add_on_trains).to eq({})
    end

    it 'carries the marker to the combined train' do
      two = give!(major, card('2+2'))
      three = give!(major, card('3'))
      mark!(two)
      combined = combine!(two, three)

      expect(game.add_on_train?(:one_plus_one_marker, combined)).to be(true)
    end

    it 'offers the combined train but not its components' do
      two = give!(major, card('2+2'))
      three = give!(major, card('3'))
      combined = combine!(two, three)

      expect(step.choices.keys).to eq(["one_plus_one_marker:#{combined.id}"])
    end

    it 'offers both when the RR has a Pullman and the marker' do
      give!(major, card('Pullman'))
      three = give!(major, card('3'))

      expect(step.choices).to eq(
        "pullman:#{three.id}" => 'Pullman on 3 train',
        "one_plus_one_marker:#{three.id}" => '+1+1 marker on 3 train',
      )
      expect(step.choice_name).to eq('Attach to a train')
      step.process_choose(Engine::Action::Choose.new(major, choice: "pullman:#{three.id}"))
      expect(game.add_on_train?(:pullman, three)).to be(true)
    end

    it 'shows the marker in the train name' do
      give!(major, card('Pullman'))
      three = give!(major, card('3'))
      mark!(three)
      expect(step.train_name(major, three)).to eq('3 (+1+1 marker)')

      step.process_choose(Engine::Action::Choose.new(major, choice: "pullman:#{three.id}"))
      expect(step.train_name(major, three)).to eq('3 (Pullman, +1+1 marker)')
    end

    it 'attaches each add-on independently and names both on the train' do
      give!(major, card('Pullman'))
      three = give!(major, card('3'))
      mark!(three)
      step.process_choose(Engine::Action::Choose.new(major, choice: "pullman:#{three.id}"))

      expect(game.add_on_train?(:pullman, three)).to be(true)
      expect(game.add_on_train?(:one_plus_one_marker, three)).to be(true)
      expect(step.train_name(major, three)).to eq('3 (Pullman, +1+1 marker)')
    end

    it 'rejects a marker choice for an operated train' do
      three = give!(major, card('3'))
      three.operated = true

      expect { mark!(three) }.to raise_error(Engine::GameError, /\+1\+1 marker/)
    end

    it 'rejects a marker choice for a foreign train' do
      other = start_major!(game, 'GWR', player)
      foreign = give!(other, card('3'))

      expect { mark!(foreign) }.to raise_error(Engine::GameError, /\+1\+1 marker/)
    end
  end

  context 'with the marker assigned' do
    before { game.add_minor_charter!(minor_l, major) }

    def run_train(name, variant: nil)
      train = give!(major, card(name))
      train.variant = variant if variant
      train
    end

    def route_for(train, stops = [])
      route = Engine::Route.new(game, game.phase, train)
      allow(route).to receive(:visited_stops).and_return(stops)
      allow(route).to receive(:stops).and_return(stops)
      allow(route).to receive(:hexes).and_return(stops.map(&:hex))
      route
    end

    def cities(*ids)
      ids.map { |id| game.hex_by_id(id).tile.cities.first }
    end

    def town
      game.hex_by_id('AE6').tile.towns.first
    end

    def base(stop, train)
      stop.route_base_revenue(game.phase, train)
    end

    def rows(train)
      game.train_distance(train).to_h { |row| [row['nodes'].include?('city') ? :city : :town, row] }
    end

    let(:five_cities) { cities('M28', 'N31', 'G26', 'K46', 'X33') }

    describe 'train limit' do
      it 'runs a 2+2 as a 3+3' do
        train = run_train('2+2')
        mark!(train)

        expect(rows(train)[:city].values_at('pay', 'visit')).to eq([3, 3])
        expect(rows(train)[:town]['pay']).to eq(3)
      end

      it 'runs an 8+8 as a 9+9' do
        train = run_train('8+8')
        mark!(train)

        expect(rows(train)[:city].values_at('pay', 'visit')).to eq([9, 9])
        expect(rows(train)[:town]['pay']).to eq(9)
      end

      it 'runs a 4 as a 5+1' do
        train = run_train('4')
        mark!(train)

        expect(rows(train)[:city].values_at('pay', 'visit')).to eq([5, 5])
        expect(rows(train)[:town]['pay']).to eq(1)
      end

      it 'runs a 4D as five cities and one town' do
        train = run_train('7+7', variant: '4D')
        mark!(train)

        expect(rows(train)[:city].values_at('pay', 'visit')).to eq([5, 5])
        expect(rows(train)[:town]['pay']).to eq(1)
      end

      it 'leaves the train distance untouched' do
        train = run_train('2+2')
        original = train.distance.map(&:dup)
        mark!(train)
        game.train_distance(train)

        expect(train.distance).to eq(original)
      end

      it 'returns the train distance itself for an unmarked train' do
        train = run_train('2+2')

        expect(game.train_distance(train)).to equal(train.distance)
      end

      it 'adds the marker to the stops of a combined train (§12.1)' do
        combined = combine!(run_train('2+2'), run_train('3'))
        mark!(combined)

        expect(rows(combined)[:city]['pay']).to eq(6)
        expect(rows(combined)[:town]['pay']).to eq(3)
      end

      it 'accepts a third city on a marked 2+2' do
        train = run_train('2+2')
        mark!(train)
        stops = cities('M28', 'N31', 'K46')

        expect { game.check_distance(route_for(train, stops), stops) }.not_to raise_error
      end

      it 'rejects a third city on an unmarked 2+2' do
        train = run_train('2+2')
        stops = cities('M28', 'N31', 'K46')

        expect { game.check_distance(route_for(train, stops), stops) }.to raise_error(Engine::GameError)
      end
    end

    describe 'revenue' do
      describe 'chosen stops' do
        def computed(train, available)
          allow(train).to receive(:requires_token).and_return(false)
          route = route_for(train)
          allow(game).to receive(:revenue_stops).with(route).and_return(available)
          stops = game.compute_stops(route)
          [stops, game.revenue_for(route, stops)]
        end

        let(:towns) { %w[AE6 AE74].map { |id| game.hex_by_id(id).tile.towns.first } }

        it 'picks all three cities for a marked 2+2' do
          train = run_train('2+2')
          mark!(train)
          available = cities('M28', 'N31', 'K46')
          stops, revenue = computed(train, available)

          expect(stops).to match_array(available)
          expect(revenue).to eq(available.sum { |stop| base(stop, train) })
        end

        it 'picks only two cities for an unmarked 2+2' do
          train = run_train('2+2')
          stops, = computed(train, cities('M28', 'N31', 'K46'))

          expect(stops.size).to eq(2)
        end

        it 'picks six stops, five places and one extra town, for a marked 4' do
          train = run_train('4')
          mark!(train)
          stops, revenue = computed(train, five_cities + towns)

          expect(stops.size).to eq(6)
          expect(revenue).to eq(130)
        end

        it 'picks only four stops for an unmarked 4' do
          stops, = computed(run_train('4'), five_cities + towns)

          expect(stops.size).to eq(4)
        end

        it 'picks five cities and one town for a marked 4D, the lowest city and the town single' do
          game.phase.next! until game.phase.name == '7'
          train = run_train('7+7', variant: '4D')
          mark!(train)
          stops, revenue = computed(train, five_cities + towns)
          sum = five_cities.sum { |stop| base(stop, train) }
          lowest = five_cities.map { |stop| base(stop, train) }.min

          expect(stops.size).to eq(6)
          expect(stops).to include(*five_cities)
          expect(stops.count(&:town?)).to eq(1)
          expect(revenue).to eq((2 * sum) - lowest + base(towns.first, train))
        end

        it 'scores a marked 4D the same inside and outside compute_stops' do
          game.phase.next! until game.phase.name == '7'
          train = run_train('7+7', variant: '4D')
          mark!(train)
          stops, inside = computed(train, five_cities + towns)

          expect(game.revenue_for(route_for(train, stops), stops)).to eq(inside)
          expect(game.instance_variable_get(:@one_plus_one_city_limit)).to be_nil
        end
      end

      context 'with a D train' do
        let(:train) { run_train('7+7', variant: '4D').tap { |t| mark!(t) } }

        before { game.phase.next! until game.phase.name == '7' }

        it 'does not double the lowest city on a five city route' do
          route = route_for(train, five_cities)
          sum = five_cities.sum { |stop| base(stop, train) }
          lowest = five_cities.map { |stop| base(stop, train) }.min

          expect(game.revenue_for(route, five_cities)).to eq((2 * sum) - lowest)
        end

        it 'doubles every city within the unmarked limit' do
          stops = five_cities.first(4)
          sum = stops.sum { |stop| base(stop, train) }

          expect(game.revenue_for(route_for(train, stops), stops)).to eq(2 * sum)
        end

        it 'does not double the additional town' do
          stops = five_cities.first(4) + [town]
          sum = five_cities.first(4).sum { |stop| base(stop, train) }

          expect(game.revenue_for(route_for(train, stops), stops)).to eq((2 * sum) + base(town, train))
        end

        it 'adds exactly the Pullman bonus on top' do
          route = route_for(train, five_cities)
          before = game.revenue_for(route, five_cities)
          give!(major, card('Pullman'))
          step.process_choose(Engine::Action::Choose.new(major, choice: "pullman:#{train.id}"))

          expect(game.pullman_bonus(route)).to eq(70)
          expect(game.revenue_for(route, five_cities) - before).to eq(70)
        end
      end

      it 'keeps the Pullman level of a marked 3' do
        give!(major, card('Pullman'))
        train = run_train('3')
        step.process_choose(Engine::Action::Choose.new(major, choice: "pullman:#{train.id}"))
        mark!(train)

        expect(game.pullman_bonus(route_for(train))).to eq(30)
      end
    end

    describe 'sea' do
      it 'raises the pool need level of a marked train by one' do
        train = run_train('3')
        mark!(train)

        expect(game.send(:city_limit_level, train)).to eq(4)
      end

      it 'raises the largest city limit by one with the marker' do
        other = start_major!(game, 'GWR', player)
        give!(major, card('3'))
        give!(other, card('3'))

        expect(game.largest_city_limit(major)).to eq(game.largest_city_limit(other) + 1)
      end

      it 'reduces the city row of a marked train by the sea distance' do
        train = run_train('3')
        mark!(train)
        route = route_for(train)
        allow(game).to receive(:sea_distance).with(route).and_return(1)

        expect(game.route_train_distance(route, train).find { |row| row['nodes'].include?('city') }['pay']).to eq(3)
      end
    end
  end

  it 'offers the marker to minor L itself' do
    two = give!(minor_l, card('2+2'))
    allow(step).to receive(:current_entity).and_return(minor_l)

    expect(step.add_on_choices(minor_l, :one_plus_one_marker)).to eq([two])
    expect(step.actions(minor_l)).to include('choose')
    expect(step.choices.keys).to include("one_plus_one_marker:#{two.id}")
  end

  it 'offers no marker without L ability' do
    give!(major, card('3'))

    expect(step.actions(major)).not_to include('choose')
    expect(game.one_plus_one_marker?(major)).to be(false)
  end
end
