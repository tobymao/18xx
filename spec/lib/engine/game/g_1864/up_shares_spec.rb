# frozen_string_literal: true

require 'spec_helper'

describe 'G1864 UP share purchase' do
  let(:game) { Engine::Game::G1864::Game.new(%w[alice bob carol], seed: 1) }

  def drain_union_pacific_ipo!(game)
    game.players.each { |player| game.bank.spend(2000, player) }
    buyers = [0, 1, 2, 0, 1, 2, 0, 1, 2, 0].map { |i| game.players[i] }
    buyers.each { |player| game.share_pool.buy_shares(player, game.union_pacific.shares.first) }
  end

  def start_minor!(game, minor, player)
    game.bank.spend(1000, player)
    game.par_corporation(minor, game.stock_market.market.first.find { |sp| sp&.price == 100 })
    game.share_pool.buy_shares(player, minor.shares.first)
    minor
  end

  def step
    Engine::Game::G1864::Step::UPShares.new(game, [])
  end

  it 'offers a share to the owner of a regionalized minor' do
    alice = game.players.first
    minor = start_minor!(game, game.corporation_by_id('N'), alice)

    game.nationalize!(minor)

    expect(game.pending_up_share_buyers).to eq([{ player: alice, shares: 1 }])
    expect(step.actions(alice)).to eq(%w[choose])
  end

  it 'offers one share per two shares held of a regionalized major, president first then clockwise' do
    game.event_green_minors_available!
    major = game.corporations.find { |c| c.type == :major }
    game.par_corporation(major, game.stock_market.market.first.find { |sp| sp&.price == 100 })
    alice, bob, carol = game.players
    game.players.each { |player| game.bank.spend(1000, player) }
    4.times { game.share_pool.buy_shares(bob, major.shares.first) }
    2.times { game.share_pool.buy_shares(carol, major.shares.first) }
    game.share_pool.buy_shares(alice, major.shares.first)

    game.nationalize!(major)

    expect(game.pending_up_share_buyers).to eq([{ player: bob, shares: 2 }, { player: carol, shares: 1 }])
  end

  it 'buys a share for the bank at the UP price, leaving the UP without cash' do
    alice = game.players.first
    game.nationalize!(start_minor!(game, game.corporation_by_id('N'), alice))
    cash_before = alice.cash
    bank_before = game.bank.cash

    step.process_choose(Engine::Action::Choose.new(alice, choice: '1'))

    expect(alice.num_shares_of(game.union_pacific)).to eq(1)
    expect(alice.cash).to eq(cash_before - 80)
    expect(game.bank.cash).to eq(bank_before + 80)
    expect(game.union_pacific.cash).to eq(0)
    expect(game.pending_up_share_buyers).to be_empty
  end

  it 'offers a button per share count with its cost, and buys the chosen count in one go' do
    alice, bob = game.players
    game.bank.spend(1000, alice)
    game.pending_up_share_buyers.replace([{ player: alice, shares: 3 }, { player: bob, shares: 1 }])
    up_step = step

    expect(up_step.choices).to eq(
      '1' => 'Buy 1 share ($80)',
      '2' => 'Buy 2 shares ($160)',
      '3' => 'Buy 3 shares ($240)',
      'pass' => 'Decline',
    )

    up_step.process_choose(Engine::Action::Choose.new(alice, choice: '2'))

    expect(alice.num_shares_of(game.union_pacific)).to eq(2)
    expect(game.pending_up_share_buyers).to eq([{ player: bob, shares: 1 }])
  end

  it 'only offers the counts the player can afford' do
    alice = game.players.first
    alice.spend(alice.cash - 170, game.bank)
    game.pending_up_share_buyers.replace([{ player: alice, shares: 3 }])

    expect(step.choices.keys).to eq(%w[1 2 pass])
    expect { step.process_choose(Engine::Action::Choose.new(alice, choice: '3')) }
      .to raise_error(Engine::GameError)
  end

  it 'finishes one minor\'s regionalization before regionalizing the next' do
    alice, bob = game.players
    first = start_minor!(game, game.corporation_by_id('N'), alice)
    second = start_minor!(game, game.corporations.find { |c| c.type == :minor && c != first }, bob)
    bob_cash = bob.cash

    game.nationalize!(first)
    game.nationalize!(second)

    expect(game.corporations).to include(second)
    expect(bob.cash).to eq(bob_cash)
    expect(game.pending_up_share_buyers).to eq([{ player: alice, shares: 1 }])

    step.process_choose(Engine::Action::Choose.new(alice, choice: '1'))

    expect(game.corporations).not_to include(second)
    expect(bob.cash).to be > bob_cash
    expect(game.pending_up_share_buyers).to eq([{ player: bob, shares: 1 }])
  end

  it 'regionalizes every queued minor when the IPO is empty' do
    alice, bob = game.players
    first = start_minor!(game, game.corporation_by_id('N'), alice)
    second = start_minor!(game, game.corporations.find { |c| c.type == :minor && c != first }, bob)
    game.nationalize!(first)
    game.nationalize!(second)
    drain_union_pacific_ipo!(game)

    step.skip!

    expect(game.corporations).not_to include(first, second)
    expect(game.pending_up_share_buyers).to be_empty
  end

  it 'rejects a purchase by a player who is not next in line' do
    alice, bob = game.players
    game.nationalize!(start_minor!(game, game.corporation_by_id('N'), alice))

    expect { step.process_choose(Engine::Action::Choose.new(bob, choice: '1')) }
      .to raise_error(Engine::GameError)
  end

  it 'does not offer the purchase when it would exceed the certificate limit' do
    alice = game.players.first
    game.nationalize!(start_minor!(game, game.corporation_by_id('N'), alice))
    allow(game).to receive(:num_certs).with(alice).and_return(game.cert_limit(alice))

    expect(step.choices.keys).to eq(%w[pass])
    expect { step.process_choose(Engine::Action::Choose.new(alice, choice: '1')) }
      .to raise_error(Engine::GameError)
  end

  it 'reserves the UP IPO shares until phase 6' do
    up = game.union_pacific
    sr_step = game.round.active_step
    alice = game.players.first

    expect(up.reserved_shares.size).to eq(10)
    expect(sr_step.can_buy?(alice, up.shares.first.to_bundle)).to be_falsey

    game.event_up_ipo_purchasable!

    expect(up.reserved_shares).to be_empty
    expect(sr_step.can_buy?(alice, up.shares.first.to_bundle)).to be(true)
  end

  it 'releases the reservation on UP shares bought after regionalization' do
    alice = game.players.first
    game.nationalize!(start_minor!(game, game.corporation_by_id('N'), alice))

    step.process_choose(Engine::Action::Choose.new(alice, choice: '1'))

    expect(alice.shares_of(game.union_pacific).map(&:buyable)).to eq([true])
    expect(game.union_pacific.reserved_shares.size).to eq(9)
  end

  it 'blocks selling UP shares before the UP operates' do
    sr_step = Engine::Game::G1864::Step::BuySellParShares.new(game, [])
    bundle = game.union_pacific.shares.first.to_bundle

    expect(sr_step.can_sell?(game.players.first, bundle)).to be(false)
  end

  it 'rejects buying a UP IPO share in a stock round before phase 6' do
    sr_step = game.round.active_step
    alice = game.players.first
    share = game.union_pacific.ipo_shares.first
    game.phase.next! while game.phase.name.to_i < 5

    expect { sr_step.process_buy_shares(Engine::Action::BuyShares.new(alice, shares: [share], share_price: share.price)) }
      .to raise_error(Engine::GameError, /Cannot buy a share of UP/)
  end

  it 'shows the UP in the stock round and offers its IPO from phase 6' do
    sr_step = game.round.active_step
    alice = game.players.first

    expect(game.sorted_corporations).to include(game.union_pacific)
    expect(sr_step.can_buy_any_from_ipo?(alice)).to be_falsey

    game.event_up_ipo_purchasable!

    expect(sr_step.can_buy_any_from_ipo?(alice)).to be(true)
  end

  it 'makes the first player to hold a share the President' do
    alice = game.players.first
    game.share_pool.buy_shares(alice, game.union_pacific.shares.first)

    expect(game.union_pacific.owner).to eq(alice)
    expect(game.union_pacific.presidents_share.owner).to eq(alice)
  end

  it 'passes the presidency to a player who overtakes the holding' do
    alice, bob = game.players
    game.share_pool.buy_shares(alice, game.union_pacific.shares.first)
    2.times { game.share_pool.buy_shares(bob, game.union_pacific.shares.first) }

    expect(game.union_pacific.owner).to eq(bob)
  end

  it 'caps a player at 60% of the UP' do
    alice = game.players.first
    game.bank.spend(1000, alice)
    game.event_up_ipo_purchasable!
    6.times { game.share_pool.buy_shares(alice, game.union_pacific.shares.first) }
    step = game.round.active_step

    expect(step.can_buy?(alice, game.union_pacific.shares.first&.to_bundle)).to be(false)
  end

  it 'skips the purchase silently when the IPO is empty' do
    drain_union_pacific_ipo!(game)
    expect(game.union_pacific.shares).to be_empty

    game.pending_up_share_buyers << { player: game.players.first, shares: 1 }
    up_step = step

    expect(up_step.actions(game.players.first)).to eq([])
    expect { up_step.skip! }.not_to raise_error
    expect(game.pending_up_share_buyers).to be_empty
    expect(up_step.active?).to be(false)
  end

  it 'still serves a later regionalization once shares exist, proving the queue was not poisoned' do
    drain_union_pacific_ipo!(game)
    alice, bob = game.players

    game.pending_up_share_buyers << { player: alice, shares: 1 }
    step.skip!
    expect(game.pending_up_share_buyers).to be_empty

    returned = alice.shares_of(game.union_pacific).first
    game.share_pool.transfer_shares(returned.to_bundle, game.union_pacific)
    expect(game.union_pacific.shares).not_to be_empty

    game.pending_up_share_buyers << { player: bob, shares: 1 }

    up_step = step
    expect(up_step.actions(bob)).to eq(%w[choose])

    up_step.process_choose(Engine::Action::Choose.new(bob, choice: '1'))

    expect(game.pending_up_share_buyers).to be_empty
    expect(bob.num_shares_of(game.union_pacific)).to be_positive
  end

  it 'drops a shareholder\'s remaining entitlement when they pass, advancing the queue' do
    alice, bob = game.players
    game.pending_up_share_buyers.replace([{ player: alice, shares: 3 }, { player: bob, shares: 1 }])

    up_step = step
    up_step.process_choose(Engine::Action::Choose.new(alice, choice: 'pass'))

    expect(game.pending_up_share_buyers).to eq([{ player: bob, shares: 1 }])
    expect(up_step.current_entity).to eq(bob)
  end
end
