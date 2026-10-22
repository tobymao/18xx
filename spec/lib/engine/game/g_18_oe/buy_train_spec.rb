# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE buy trains (§11.6)' do
  include G18OESpecHelpers

  let(:game) { game_at_or1 }

  def step
    game.round.active_step
  end

  def advance_to_buy_train!(game, corp_id, cash: 0)
    corporation = advance_to!(game, corp_id)
    game.bank.spend(cash, corporation) if cash.positive?
    or_step!(game) until game.round.active_step.is_a?(Engine::Game::G18OE::Step::BuyTrain)
    corporation
  end

  def card(name)
    game.depot.upcoming.find { |t| t.name == name }
  end

  def owned_trains
    game.corporations.select(&:floated?).flat_map(&:trains).map(&:name)
  end

  it 'makes a railroad buy its reserved 2+2 in its first OR (§11.6.1)' do
    minor = advance_to_buy_train!(game, game.minor_regional_order.first.id)

    expect(step.must_buy_train?(minor)).to be(true)
    expect(step.buyable_trains(minor).map(&:name).uniq).to eq(['2+2'])
  end

  it 'sells no level 3 in the first OR of the game (§11.6)' do
    minor = advance_to_buy_train!(game, game.minor_regional_order.first.id)
    buy_step = step
    or_step!(game)

    expect(minor.trains.map(&:name)).to eq(['2+2'])
    expect(buy_step.buyable_trains(minor)).to eq([])
  end

  it 'sells level 3 trains from the second OR once the Major RR Phase began (§8.3)' do
    finish_or!(game)
    lnwr = advance_to_buy_train!(game, 'LNWR', cash: 300)
    names = step.buyable_trains(lnwr).map(&:name)

    expect(names).to include('3')
    expect(names).not_to include('2+2')
  end

  it 'starts phase 3 with the first level 3 train (§5.2)' do
    finish_or!(game)
    lnwr = advance_to_buy_train!(game, 'LNWR', cash: 300)
    cash = lnwr.cash
    act!(game, Engine::Action::BuyTrain.new(lnwr, train: card('3'), price: 200))

    expect(game.phase.name).to eq('3')
    expect(cash - lnwr.cash).to eq(200)
  end

  it 'sells the 3+3 side for £225 (§11.6.4)' do
    finish_or!(game)
    lnwr = advance_to_buy_train!(game, 'LNWR', cash: 300)
    act!(game, Engine::Action::BuyTrain.new(lnwr, train: card('3'), price: 225, variant: '3+3'))

    expect(lnwr.trains.map(&:name)).to include('3+3')
  end

  it 'allows buying from other railroads only in the Major RR Phase (§8.2, §8.3)' do
    expect(game_at_or1(regionals: 17).can_buy_train_from_others?).to be(false)
    expect(game.can_buy_train_from_others?).to be(true)
  end

  it 'makes a major without trains buy one (§11.6)' do
    game = game_at_sr2
    major = convert!(game, game.corporations.find { |c| c.type == :regional && c.president?(game.current_entity) })
    finish_sr!(game)
    advance_to_buy_train!(game, major.id)
    game.rust_trains!(game.depot.upcoming.find { |t| t.name == '4' }, major)

    expect(major.trains).to be_empty
    expect(game.round.active_step.must_buy_train?(major)).to be(true)
  end

  it 'rusts every 2+2 when the first level 4 is bought (§5.2)' do
    finish_or!(game)
    game.rust_trains!(card('4'), game.current_entity)

    expect(owned_trains).not_to include('2+2')
  end

  it 'ends the reserved train obligation in phase 4 (§11.6.1)' do
    2.times { game.phase.next! }

    expect(game.train_obligation_active?).to be(false)
  end

  it 'releases level 8 trains after the fourth level 7 is sold (§11.6)' do
    game.depot.upcoming.reject { |t| %w[7+7 8+8].include?(t.name) }.each { |t| game.depot.remove_train(t) }
    game.phase.next! while game.phase.name != '6'
    expect(game.level8_train_available?).to be(false)

    game.phase.next!
    3.times { game.depot.remove_train(card('7+7')) }
    expect(game.level8_train_available?).to be(false)

    game.depot.remove_train(card('7+7'))
    expect(game.level8_train_available?).to be(true)
  end

  it 'limits 4D and 5D trains to 4 and 5 cities (§11.3.3)' do
    city_limits = { '7+7' => '4D', '8+8' => '5D' }.to_h do |name, side|
      [side, card(name).variants[side][:distance].find { |d| d['nodes'].include?('city') }['visit']]
    end

    expect(city_limits).to eq('4D' => 4, '5D' => 5)
  end
end
