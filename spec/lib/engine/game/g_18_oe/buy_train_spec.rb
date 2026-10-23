# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE buy trains (§11.6)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:player) { game.players.first }
  let(:minor) { start_minor!(game, 'K', player, 'RU') }
  let(:round) do
    minor
    enter_round!(game, game.operating_round(1))
  end
  let(:step) { round_step(round, Engine::Game::G18OE::Step::BuyTrain) }

  def card(name)
    game.depot.upcoming.find { |t| t.name == name }
  end

  def after_first_or!
    game.instance_variable_set(:@first_or_complete, true)
    game.depot.upcoming.select { |t| t.name == '2+2' }.each { |t| game.depot.remove_train(t) }
  end

  def buy!(entity, train, price, variant: nil)
    step.process_buy_train(Engine::Action::BuyTrain.new(entity, train: train, price: price, variant: variant))
  end

  it 'makes a railroad buy its reserved 2+2 in its first OR (§11.6.1)' do
    expect(step.must_buy_train?(minor)).to be(true)
    expect(step.buyable_trains(minor).map(&:name).uniq).to eq(['2+2'])
  end

  it 'records that the reserved 2+2 was bought (§11.6.1)' do
    buy!(minor, card('2+2'), 100)

    expect(game.fulfilled_train_obligation?(minor)).to be(true)
  end

  it 'sells no level 3 before the Major RR Phase (§8.2)' do
    game.fulfill_train_obligation!(minor)
    after_first_or!

    expect(step.buyable_trains(minor)).to eq([])
  end

  it 'sells no level 3 in the first OR of the game (§11.6)' do
    allow(game).to receive(:major_phase?).and_return(true)
    game.fulfill_train_obligation!(minor)

    expect(step.buyable_trains(minor)).to eq([])
  end

  it 'sells level 3 trains after the first OR once the Major RR Phase began (§8.3)' do
    allow(game).to receive(:major_phase?).and_return(true)
    game.fulfill_train_obligation!(minor)
    after_first_or!
    names = step.buyable_trains(minor).map(&:name)

    expect(names).to include('3')
    expect(names).not_to include('2+2')
  end

  it 'unlocks level 3 trains when the first OR ends' do
    allow(game).to receive(:major_phase?).and_return(true)
    round
    game.instance_variable_set(:@operating_rounds, 2)
    game.next_round!

    expect(game.non_starter_trains_available?).to be(true)
  end

  it 'starts phase 3 with the first level 3 train (§5.2)' do
    allow(game).to receive(:major_phase?).and_return(true)
    game.fulfill_train_obligation!(minor)
    after_first_or!
    fund!(game, minor, 300)
    cash = minor.cash
    buy!(minor, card('3'), 200)

    expect(game.phase.name).to eq('3')
    expect(cash - minor.cash).to eq(200)
  end

  it 'sells the 3+3 side for £225 (§11.6.4)' do
    allow(game).to receive(:major_phase?).and_return(true)
    game.fulfill_train_obligation!(minor)
    after_first_or!
    fund!(game, minor, 300)
    buy!(minor, card('3'), 225, variant: '3+3')

    expect(minor.trains.map(&:name)).to eq(['3+3'])
  end

  it 'allows buying from other railroads only in the Major RR Phase (§8.2, §8.3)' do
    expect(game.can_buy_train_from_others?).to be(false)

    allow(game).to receive(:major_phase?).and_return(true)
    expect(game.can_buy_train_from_others?).to be(true)
  end

  it 'makes a major without trains buy one (§11.6)' do
    major = start_major!(game, 'LNWR', player)
    game.fulfill_train_obligation!(major)
    round = enter_round!(game, game.operating_round(1))

    expect(round_step(round, Engine::Game::G18OE::Step::BuyTrain).must_buy_train?(major)).to be(true)
  end

  it 'rusts every 2+2 when the first level 4 is bought (§5.2)' do
    game.buy_train(minor, card('2+2'), :free)
    game.rust_trains!(card('4'), minor)

    expect(minor.trains).to be_empty
  end

  it 'ends the reserved train obligation in phase 4 (§11.6.1)' do
    2.times { game.phase.next! }

    expect(game.train_obligation_active?).to be(false)
  end

  it 'puts the level 8 card under the fourth level 7 train (§11.6)' do
    level_7s = game.depot.upcoming.select { |t| t.name == '7+7' }
    expected = Array.new(level_7s.size) { |i| i == 3 ? ['level_8_available'] : [] }

    expect(level_7s.map { |t| t.events.map { |e| e['type'] } }).to eq(expected)
  end

  it 'makes level 8 trains buyable once the event fires' do
    expect(game.level8_train_available?).to be(false)

    game.event_level_8_available!

    expect(game.level8_train_available?).to be(true)
  end

  it 'limits 4D and 5D trains to 4 and 5 cities (§11.3.3)' do
    city_limits = { '7+7' => '4D', '8+8' => '5D' }.to_h do |name, side|
      [side, card(name).variants[side][:distance].find { |d| d['nodes'].include?('city') }['visit']]
    end

    expect(city_limits).to eq('4D' => 4, '5D' => 5)
  end
end
