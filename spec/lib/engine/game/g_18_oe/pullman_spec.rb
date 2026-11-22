# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE Pullman cars (§11.6.2)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:player) { game.players.first }

  def card(name)
    game.depot.upcoming.find { |t| t.name == name }
  end

  def give!(corporation, train)
    game.buy_train(corporation, train, :free)
    train
  end

  def depot_pullmans
    game.depot.upcoming.count { |t| game.pullman?(t) }
  end

  def advance_to_phase!(game_state, phase_name)
    game_state.phase.next! until game_state.phase.name == phase_name
    game_state.depot.depot_trains(clear: true)
  end

  it 'attaches the pullmans_available event to the first 4 train' do
    expect(card('4').events).to include({ 'type' => 'pullmans_available' })
  end

  it 'marks Pullmans as extra trains that do not count against the train limit' do
    expect(card('Pullman').extra).to be(true)
    expect(card('4').extra).to be(false)
  end

  it 'adds ten Pullmans available from Phase 4' do
    pullmans = game.depot.upcoming.select { |t| game.pullman?(t) }

    expect(pullmans.size).to eq(10)
    expect(pullmans.map(&:available_on).uniq).to eq(['4'])
  end

  it 'gives Minor M a free Pullman when Phase 4 starts' do
    m = start_minor!(game, 'M', player, 'RU')
    cash = m.cash

    game.event_pullmans_available!

    expect(game.pullman(m)).not_to be_nil
    expect(m.cash).to eq(cash)
    expect(depot_pullmans).to eq(9)
  end

  it 'gives the free Pullman to the major M merged into' do
    m = start_minor!(game, 'M', player, 'RU')
    major = start_major!(game, 'LNWR', player)
    game.merged_minors[major] << m

    game.event_pullmans_available!

    expect(game.pullman(major)).not_to be_nil
    expect(game.pullman(m)).to be_nil
  end

  it 'gives no free Pullman when M is not floated' do
    game.event_pullmans_available!

    expect(depot_pullmans).to eq(10)
  end

  it 'does not count a Pullman against the train limit' do
    minor = start_minor!(game, 'K', player, 'RU')
    advance_to_phase!(game, '4')
    give!(minor, card('4'))
    give!(minor, card('Pullman'))

    expect(game.num_corp_trains(minor)).to eq(1)
    expect(game.crowded_corps).not_to include(minor)
  end

  it 'does not let a Pullman satisfy must-own-a-train' do
    major = start_major!(game, 'LNWR', player)
    give!(major, card('Pullman'))
    round = enter_round!(game, game.operating_round(1))
    step = round_step(round, Engine::Game::G18OE::Step::BuyTrain)

    expect(step.must_buy_train?(major)).to be(true)
    expect(game.route_trains(major)).to be_empty
  end

  it 'keeps the Pullman when the other trains rust' do
    major = start_major!(game, 'LNWR', player)
    two = give!(major, card('2+2'))
    give!(major, card('Pullman'))

    game.rust(two)

    expect(game.pullman(major)).not_to be_nil
    expect(game.trainless?(major)).to be(true)
  end

  it 'does not offer a Pullman for phase-change discard' do
    minor = start_minor!(game, 'K', player, 'RU')
    give!(minor, card('Pullman'))
    step = Engine::Step::DiscardTrain.new(game, [])

    expect(step.trains(minor)).to be_empty
  end

  describe 'emergency train purchase' do
    before do
      game.depot.upcoming.select { |t| %w[2+2 3].include?(t.name) }.each { |t| game.depot.remove_train(t) }
      advance_to_phase!(game, '4')
    end

    it 'ignores Pullmans when finding the cheapest depot train' do
      expect(game.depot.min_depot_train.name).not_to eq('Pullman')
      expect(game.depot.min_depot_price).to eq(game.depot.depot_trains.reject(&:extra).map(&:price).min)
    end

    it 'makes a trainless major with too little cash buy the cheapest real train' do
      major = start_major!(game, 'LNWR', player)
      major.spend(major.cash, game.bank) if major.cash.positive?
      round = enter_round!(game, game.operating_round(1))
      step = round_step(round, Engine::Game::G18OE::Step::BuyTrain)

      expect(step.buyable_trains(major).map(&:name)).not_to include('Pullman')
    end
  end

  describe 'emergency train purchase with a train owned' do
    it 'keeps the Pullman offered when the major cannot afford the cheapest real train' do
      game.depot.upcoming.select { |t| %w[2+2 3 4].include?(t.name) }.each { |t| game.depot.remove_train(t) }
      advance_to_phase!(game, '5')
      major = start_major!(game, 'LNWR', player)
      give!(major, game.train_by_id('4-0'))
      major.spend(major.cash, game.bank) if major.cash.positive?
      fund!(game, major, 200)
      round = enter_round!(game, game.operating_round(1))
      step = round_step(round, Engine::Game::G18OE::Step::BuyTrain)

      expect(game.depot.min_depot_price).to be > 200
      expect(step.buyable_trains(major).map(&:name)).to include('Pullman')
    end
  end

  describe 'buying' do
    let(:major) { fund!(game, start_major!(game, 'LNWR', player), 500) }
    let(:step) do
      round = enter_round!(game, game.operating_round(1))
      round_step(round, Engine::Game::G18OE::Step::BuyTrain)
    end

    def names(entity)
      step.buyable_trains(entity).map(&:name)
    end

    def buy!(entity, train, price)
      step.process_buy_train(Engine::Action::BuyTrain.new(entity, train: train, price: price))
    end

    def pullman_card
      game.depot.upcoming.find { |t| game.pullman?(t) }
    end

    it 'offers no Pullman before Phase 4' do
      major

      expect(names(major)).not_to include('Pullman')
    end

    it 'offers a Pullman in Phase 4' do
      major
      advance_to_phase!(game, '4')

      expect(names(major)).to include('Pullman')
    end

    it 'offers no second Pullman' do
      major
      advance_to_phase!(game, '4')
      give!(major, pullman_card)

      expect(names(major)).not_to include('Pullman')
    end

    it 'offers a Pullman at the train limit but no other train' do
      major
      advance_to_phase!(game, '4')
      game.train_limit(major).times { give!(major, game.depot.upcoming.find { |t| %w[4 3 2+2].include?(t.name) }) }

      expect(game.num_corp_trains(major)).to eq(game.train_limit(major))
      expect(names(major)).to eq(['Pullman'])
    end

    it 'refuses a non-Pullman train at the train limit' do
      major
      advance_to_phase!(game, '4')
      game.train_limit(major).times { give!(major, game.depot.upcoming.find { |t| %w[4 3 2+2].include?(t.name) }) }
      train = game.depot.depot_trains.find { |t| !game.pullman?(t) }

      expect { buy!(major, train, train.price) }.to raise_error(Engine::GameError, /no room for another train/)
    end

    it 'has no room at the train limit before Phase 4' do
      major
      give!(major, card('2+2'))
      give!(major, card('2+2'))
      give!(major, card('2+2'))
      give!(major, card('2+2'))

      expect(game.phase.name).to eq('2')
      expect(step.room?(major)).to be(false)
      expect(step.actions(major)).not_to include('buy_train')
    end

    it 'has no room at the train limit when the railroad already owns a Pullman' do
      major
      advance_to_phase!(game, '4')
      give!(major, pullman_card)
      game.train_limit(major).times { give!(major, game.depot.upcoming.find { |t| %w[4 3 2+2].include?(t.name) }) }

      expect(step.room?(major)).to be(false)
    end

    it 'ends a trainless major turn after the Pullman when it cannot afford a real train' do
      major
      kept = pullman_card
      game.depot.upcoming.select { |t| game.pullman?(t) ? t != kept : t.price <= 350 }.each { |t| game.depot.remove_train(t) }
      advance_to_phase!(game, '4')
      major.spend(major.cash, game.bank)
      player.spend(player.cash, game.bank) if player.cash.positive?
      game.bank.spend(500, major)
      allow(game).to receive(:can_buy_train_from_others?).and_return(false)
      expect(step.must_buy_train?(major)).to be(true)

      buy!(major, pullman_card, 150)

      expect(major.cash).to eq(350)
      expect(step.must_buy_train?(major)).to be(true)
      expect(step.active?).to be(true)
      expect(step.active_entities).to include(major)
    end

    it 'refuses a second Pullman' do
      major
      advance_to_phase!(game, '4')
      give!(major, pullman_card)

      expect { buy!(major, pullman_card, 150) }.to raise_error(Engine::GameError, /already owns a Pullman/)
    end

    it 'refuses a train owned by an abandoned minor' do
      major
      advance_to_phase!(game, '4')
      allow(game).to receive(:can_buy_train_from_others?).and_return(true)
      minor = start_minor!(game, 'M', player, 'RU')
      train = give!(minor, pullman_card)
      game.abandon_minor!(minor)

      expect { buy!(major, train, 75) }.to raise_error(Engine::GameError, /abandoned/)
    end

    it 'lets the first 4 buyer buy a Pullman in the same step' do
      major
      advance_to_phase!(game, '3')
      game.depot.upcoming.select { |t| %w[2+2 3].include?(t.name) }.each { |t| game.depot.remove_train(t) }
      game.depot.depot_trains(clear: true)
      game.fulfill_train_obligation!(major)
      allow(game).to receive(:non_starter_trains_available?).and_return(true)
      four = game.depot.upcoming.first

      fund!(game, major, 1000)
      buy!(major, four, four.price)

      expect(game.phase.name).to eq('4')
      expect(step.buyable_trains(major).map(&:name)).to include('Pullman')
      expect(step.actions(major)).to include('buy_train')
    end

    context 'with Minor M floated' do
      let!(:m) { start_minor!(game, 'M', player, 'RU') }

      before do
        major
        advance_to_phase!(game, '4')
      end

      it 'charges £150 to the bank and pays M £15' do
        buyer_cash = major.cash
        m_cash = m.cash

        buy!(major, pullman_card, 150)

        expect(major.cash).to eq(buyer_cash - 150)
        expect(m.cash).to eq(m_cash + 15)
        expect(game.pullman(major)).not_to be_nil
      end

      it 'pays the royalty to the major M merged into' do
        other = start_major!(game, 'GWR', player)
        game.merged_minors[other] << m
        cash = other.cash

        buy!(major, pullman_card, 150)

        expect(other.cash).to eq(cash + 15)
        expect(m.cash).to eq(120)
      end

      it 'pays no royalty while M is abandoned' do
        game.abandon_minor!(m)
        cash = m.cash

        buy!(major, game.depot.depot_trains.find { |t| game.pullman?(t) }, 150)

        expect(m.cash).to eq(cash)
      end

      it 'pays no royalty for an Open Market Pullman' do
        card = pullman_card
        give!(m, card)
        game.depot.reclaim_train(card)
        cash = m.cash

        buy!(major, card, 150)

        expect(m.cash).to eq(cash)
        expect(game.pullman(major)).to eq(card)
      end

      it "applies J's discount and still pays £15" do
        j = start_minor!(game, 'J', player, 'IT')
        game.add_minor_charter!(j, major)
        ability = major.all_abilities.find { |a| a.type == :train_discount }
        card = pullman_card
        m_cash = m.cash

        expect(card.min_price(ability: ability)).to eq(135)
        buy!(major, card, 135)

        expect(m.cash).to eq(m_cash + 15)
      end
    end

    context 'from another railroad' do
      let(:seller) { start_major!(game, 'GWR', player) }

      before do
        major
        advance_to_phase!(game, '4')
        give!(seller, pullman_card)
        allow(game).to receive(:can_buy_train_from_others?).and_return(true)
      end

      it 'prices a Pullman at exactly £75' do
        expect(step.spend_minmax(major, game.pullman(seller))).to eq([75, 75])
      end

      it 'rejects any other price' do
        expect { buy!(major, game.pullman(seller), 74) }.to raise_error(Engine::GameError, /exactly £75/)
      end

      it 'does not offer the other railroad Pullman when cash is below the transfer price' do
        major.spend(major.cash, game.bank)
        game.bank.spend(74, major)

        expect(step.buyable_trains(major)).not_to include(game.pullman(seller))
      end

      it 'transfers the Pullman without a royalty' do
        start_minor!(game, 'M', player, 'RU')
        card = game.pullman(seller)
        cash = game.corporation_by_id('M').cash

        buy!(major, card, 75)

        expect(game.pullman(major)).to eq(card)
        expect(game.corporation_by_id('M').cash).to eq(cash)
      end
    end
  end

  context 'merging and abandoning' do
    let(:m) { start_minor!(game, 'M', player, 'RU') }
    let(:major) { start_major!(game, 'LNWR', player) }

    before { advance_to_phase!(game, '4') }

    def pullman_card
      game.depot.upcoming.find { |t| game.pullman?(t) }
    end

    def buy_step
      round = enter_round!(game, game.operating_round(1))
      round_step(round, Engine::Game::G18OE::Step::BuyTrain)
    end

    it "keeps M's Pullman on its charter when M is abandoned" do
      held = give!(m, pullman_card)
      other = fund!(game, start_major!(game, 'GWR', player), 500)
      allow(game).to receive(:can_buy_train_from_others?).and_return(true)

      game.abandon_minor!(m)
      offered = buy_step.buyable_trains(other)

      expect(game.pullman(m)).to eq(held)
      expect(game.depot.discarded).not_to include(held)
      expect(offered).not_to include(held)
      expect(offered.map(&:name)).to include('Pullman')
    end

    it 'has no room for a RR at its train limit without a Pullman when only abandoned M holds one' do
      give!(m, pullman_card)
      game.abandon_minor!(m)
      game.depot.upcoming.select { |t| game.pullman?(t) }.each { |t| game.depot.remove_train(t) }
      game.depot.depot_trains(clear: true)
      allow(game).to receive(:can_buy_train_from_others?).and_return(true)
      game.train_limit(major).times { give!(major, game.depot.upcoming.find { |t| %w[4 3 2+2].include?(t.name) }) }

      expect(buy_step.room?(major)).to be(false)
    end

    it "gives M's Pullman to the major that buys abandoned M" do
      held = give!(m, pullman_card)
      game.abandon_minor!(m)

      game.add_minor_charter!(m, major)

      expect(game.pullman(major)).to eq(held)
    end

    it 'logs the trains taken from an abandoned minor when its charter is bought' do
      give!(m, pullman_card)
      game.abandon_minor!(m)

      game.add_minor_charter!(m, major)

      expect(game.log.map(&:message)).to include("#{major.name} takes Pullman from #{m.name}")
    end

    it 'does not log a train transfer for a minor without trains' do
      game.add_minor_charter!(m, major)

      expect(game.log.map(&:message).grep(/ takes .* from /)).to be_empty
    end

    it 'discards one Pullman when M merges into a major that owns one' do
      give!(major, pullman_card)
      give!(m, pullman_card)

      game.transfer(:trains, m, major)
      game.add_minor_charter!(m, major)

      expect(major.trains.count { |t| game.pullman?(t) }).to eq(1)
      expect(game.depot.discarded.count { |t| game.pullman?(t) }).to eq(1)
    end

    it 'does not let a merging major decline the Pullman' do
      held = give!(m, pullman_card)
      four = give!(m, game.depot.upcoming.find { |t| t.name == '4' })
      game.transfer(:trains, m, major)
      round = double('round', merge_trains: { corporation: major, trains: [held, four] })
      step = Engine::Game::G18OE::Step::MergeDiscardTrain.new(game, round)

      expect(step.send(:declinable_trains)).to eq([four])
      expect(step.trains(major)).to eq([four])
    end
  end

  context 'revenue' do
    let(:major) { start_major!(game, 'LNWR', player) }
    let(:round) do
      major
      enter_round!(game, game.operating_round(1))
    end
    let(:step) { round_step(round, Engine::Game::G18OE::Step::Route) }

    before do
      allow(game).to receive(:can_run_route?).and_return(true)
      allow(game).to receive(:sea_connectivityable?).and_return(false)
      allow(step).to receive(:current_entity).and_return(major)
    end

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

    def attach!(train)
      step.process_choose(Engine::Action::Choose.new(major, choice: "pullman:#{train.id}"))
    end

    def combine!(*trains)
      step.process_double_head_trains(Engine::Action::DoubleHeadTrains.new(major, trains: trains))
      major.trains.find { |train| game.combined_train?(train) }
    end

    context 'with a Pullman' do
      before { give!(major, card('Pullman')) }

      it "offers the RR's runnable trains for the Pullman" do
        two = run_train('2+2')
        three = run_train('3')

        expect(step.actions(major)).to include('choose')
        expect(step.choices.keys).to contain_exactly("pullman:#{two.id}", "pullman:#{three.id}")
        expect(step.choice_name).to eq('Attach to a train')
      end

      it 'adds £30 to a 3+3' do
        train = run_train('3')
        attach!(train)

        expect(game.pullman_bonus(route_for(train))).to eq(30)
      end

      it 'adds £80 to an 8+8' do
        advance_to_phase!(game, '7')
        train = run_train('8+8')
        attach!(train)

        expect(game.pullman_bonus(route_for(train))).to eq(80)
      end

      it 'adds £70 to a 4D and does not double it' do
        advance_to_phase!(game, '7')
        train = run_train('7+7', variant: '4D')
        stops = %w[M50 M28].map { |id| game.hex_by_id(id).tile.cities.first }
        route = route_for(train, stops)
        before = game.revenue_for(route, stops)
        attach!(train)

        expect(game.pullman_bonus(route)).to eq(70)
        expect(game.revenue_for(route, stops) - before).to eq(70)
      end

      it 'adds £80 to a 5D' do
        advance_to_phase!(game, '7')
        train = run_train('8+8', variant: '5D')
        attach!(train)

        expect(game.pullman_bonus(route_for(train))).to eq(80)
      end

      it 'adds nothing to a train without the Pullman' do
        three = run_train('3')
        two = run_train('2+2')
        attach!(three)

        expect(game.pullman_bonus(route_for(two))).to eq(0)
      end

      it 'adds nothing when no train was chosen' do
        three = run_train('3')

        expect(game.pullman_bonus(route_for(three))).to eq(0)
      end

      it 'appends Pullman to the revenue string and train name of the attached train' do
        three = run_train('3')
        attach!(three)

        expect(game.revenue_str(route_for(three))).to end_with(' + Pullman')
        expect(game.revenue_str(route_for(run_train('2+2')))).not_to include('Pullman')
        expect(step.train_name(major, three)).to eq('3 (Pullman)')
        expect(step.train_name(major, run_train('2+2'))).to eq('2+2')
      end

      it 'moves the Pullman when another train is chosen' do
        two = run_train('2+2')
        three = run_train('3')
        attach!(two)

        expect(step.choices.keys).to eq(["pullman:#{three.id}"])
        attach!(three)

        expect(game.pullman_bonus(route_for(two))).to eq(0)
        expect(game.pullman_bonus(route_for(three))).to eq(30)
      end

      it "adds one component's level to a combined Orient Express train" do
        two = run_train('2+2')
        three = run_train('3')
        combined = combine!(two, three)
        attach!(combined)

        expect(game.pullman_bonus(route_for(combined))).to eq(30)
      end

      it 'offers the combined train but not its components' do
        two = run_train('2+2')
        three = run_train('3')
        combined = combine!(two, three)

        expect(step.choices.keys).to eq(["pullman:#{combined.id}"])
      end

      it 'carries the Pullman over to the combined train with the highest component level' do
        two = run_train('2+2')
        three = run_train('3')
        attach!(three)
        combined = combine!(two, three)

        expect(game.pullman_bonus(route_for(combined))).to eq(30)
      end
    end

    it 'offers no choice without a Pullman' do
      run_train('3')

      expect(step.actions(major)).not_to include('choose')
    end

    it 'offers no choice with a Pullman but no runnable train' do
      give!(major, card('Pullman'))

      expect(step.actions(major)).not_to include('choose')
    end
  end
end
