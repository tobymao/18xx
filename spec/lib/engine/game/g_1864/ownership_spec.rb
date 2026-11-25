# frozen_string_literal: true

require 'spec_helper'

describe 'G1864 ownership limits' do
  let(:three) { Engine::Game::G1864::Game.new(%w[alice bob carol], seed: 1) }
  let(:two) { Engine::Game::G1864::Game.new(%w[alice bob], seed: 1) }

  def major_of(game)
    (game.corporations + game.future_corporations).find { |c| c.type == :major }
  end

  def enter_phase_6(game)
    game.phase.next! while game.phase.name.to_i < 6
    game.event_ownership_limit!
  end

  it 'leaves majors uncapped before phase 6' do
    expect(major_of(three).max_ownership_percent).to eq(100)
  end

  it 'leaves majors uncapped before phase 6 at two players too' do
    expect(major_of(two).max_ownership_percent).to eq(100)
  end

  it 'caps majors at 60% from phase 6' do
    enter_phase_6(three)

    expect(major_of(three).max_ownership_percent).to eq(60)
  end

  it 'caps majors at 70% from phase 6 in a two player game' do
    enter_phase_6(two)

    expect(major_of(two).max_ownership_percent).to eq(70)
  end

  it 'keeps a reset major at 70% at two players' do
    enter_phase_6(two)
    major = major_of(two)
    two.reset_corporation(major)

    expect(major.max_ownership_percent).to eq(70)
  end

  it 'does not require a player already above 60% to sell once phase 6 arrives' do
    major = major_of(three)
    three.par_corporation(major, three.stock_market.market.flatten.compact.find { |sp| sp.price == 100 })
    major.ipoed = true
    major.floated = true

    alice = three.players.first
    three.bank.spend(3000, alice)
    7.times { three.share_pool.buy_shares(alice, major.shares.first) }
    major.operating_history[[1, 1]] = :operated

    enter_phase_6(three)
    step = three.round.active_step

    expect(major.max_ownership_percent).to eq(60)
    expect(alice.percent_of(major)).to be > 60
    expect(step.must_sell?(alice)).to be(false)
    expect(step.can_buy?(alice, major.shares.first.to_bundle)).to be(false)
  end

  it 'shows the ownership limit that applies in each phase' do
    statuses = Engine::Game::G1864::Game::PHASES.to_h { |phase| [phase[:name], phase[:status]] }

    expect(statuses.values_at('2', '3', '4', '5')).to all(include('no_ownership_limit'))
    expect(statuses.values_at('6', '7', '8')).to all(include('ownership_limit'))
  end

  it 'keeps a regionalized major at 70% at two players' do
    enter_phase_6(two)
    major = major_of(two)
    major_id = major.id
    share_price = two.stock_market.market.flatten.compact.find { |sp| sp.price == 100 }
    two.par_corporation(major, share_price)
    major.ipoed = true
    major.floated = true

    two.nationalize!(major)
    reset_major = (two.corporations + two.future_corporations).find { |c| c.id == major_id }

    expect(reset_major).not_to be_nil
    expect(reset_major.max_ownership_percent).to eq(70)
  end

  it 'caps the UP at 60% always' do
    expect(three.union_pacific.max_ownership_percent).to eq(60)
  end

  it 'keeps the UP at 60% after phase 6 and at two players' do
    enter_phase_6(two)

    expect(two.union_pacific.max_ownership_percent).to eq(60)
  end

  it 'removes trains for a two player game' do
    expect(two.depot.upcoming.count { |t| t.name == '2' }).to eq(6)
    expect(two.depot.upcoming.count { |t| t.name == '3' }).to eq(5)
    expect(two.depot.upcoming.count { |t| t.name == '4' }).to eq(3)
  end

  it 'removes every ability card at phase 6' do
    three.event_remove_minor_abilities!

    expect(three.companies.reject(&:closed?)).to eq([])
  end

  it 'rusts the Pullman when the first 6-train starts phase 6' do
    corporation = (three.corporations + three.future_corporations).find { |c| c.trains.any? { |t| three.pullman?(t) } }
    six = three.depot.upcoming.find { |t| t.name == '6' }

    expect(corporation.trains.map(&:name)).to include('Pullman')

    three.rust_trains!(six, nil)

    expect(corporation.trains.map(&:name)).not_to include('Pullman')
  end
end
