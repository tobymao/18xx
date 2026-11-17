# frozen_string_literal: true

require 'spec_helper'

describe 'G1864 regionalization' do
  let(:game) { Engine::Game::G1864::Game.new(%w[alice bob carol], seed: 1) }
  let(:minor) { game.corporation_by_id('FE&MV') }

  it 'moves the share price one space left per loan, not two' do
    minor.loans << game.loans.pop
    game.par_corporation(minor, game.stock_market.market.first[5])
    start = minor.share_price
    before = minor.share_price

    game.nationalization_loan_movement(minor)

    expect(game.stock_market.market.first.index(minor.share_price))
      .to eq(game.stock_market.market.first.index(before) - 1)
    expect(start).not_to be_nil
  end

  it 'sends cash to the bank and removes trains from the game' do
    game.par_corporation(minor, game.stock_market.market.first[5])
    game.bank.spend(200, minor)
    train = game.depot.upcoming.first
    game.buy_train(minor, train, :free)
    bank_before = game.bank.cash

    game.nationalization_transfer_assets(minor)

    expect(minor.cash).to eq(0)
    expect(minor.trains).to be_empty
    expect(game.bank.cash).to eq(bank_before + 200)
    expect(game.depot.upcoming).not_to include(train)
    expect(game.union_pacific.trains.map(&:name)).not_to include(train.name)
  end

  it 'chooses the merger round minors only once queued regionalizations finish' do
    alice = game.players.first
    allow(game).to receive(:merge_corporations).and_return([minor])
    game.pending_up_share_buyers << { player: alice, shares: 1 }

    round = game.merger_round
    round.setup

    expect(round.entities).to be_empty
    expect(round.active_step).to be_a(Engine::Game::G1864::Step::UPShares)

    game.pending_up_share_buyers.clear
    round.after_process(Engine::Action::Pass.new(alice))

    expect(round.entities).to eq([minor])
  end
end
