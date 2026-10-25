# frozen_string_literal: true

require 'spec_helper'

describe 'G1864 Credit Mobilier' do
  let(:game) { Engine::Game::G1864::Game.new(%w[alice bob carol], seed: 1) }

  it 'starts empty and open' do
    expect(game.credit_mobilier.cash).to eq(0)
    expect(game.credit_mobilier.closed?).to be(false)
  end

  it 'receives money paid from the bank' do
    game.pay_credit_mobilier(20, from: game.bank)

    expect(game.credit_mobilier.cash).to eq(20)
  end

  it 'divides equally among players and keeps the remainder' do
    game.pay_credit_mobilier(100, from: game.bank)
    before = game.players.map(&:cash)

    game.distribute_credit_mobilier!

    expect(game.players.map(&:cash)).to eq(before.map { |c| c + 33 })
    expect(game.credit_mobilier.cash).to eq(1)
  end

  it 'pays nothing when empty' do
    before = game.players.map(&:cash)

    game.distribute_credit_mobilier!

    expect(game.players.map(&:cash)).to eq(before)
  end

  it 'returns its balance to the bank and closes at phase 4' do
    game.pay_credit_mobilier(60, from: game.bank)
    bank_before = game.bank.cash

    game.event_close_credit_mobilier!

    expect(game.credit_mobilier.cash).to eq(0)
    expect(game.bank.cash).to eq(bank_before + 60)
    expect(game.credit_mobilier.closed?).to be(true)
  end

  it 'ignores payments once closed' do
    game.event_close_credit_mobilier!
    game.pay_credit_mobilier(20, from: game.bank)

    expect(game.credit_mobilier.cash).to eq(0)
  end

  it 'is shown as an entity alongside the UP until it closes' do
    expect(game.unstarted_corporation_summary.last.first(2)).to eq([game.union_pacific, game.credit_mobilier])

    game.share_pool.buy_shares(game.players.first, game.union_pacific.ipo_shares.first)

    expect(game.unstarted_corporation_summary.last.first).to eq(game.credit_mobilier)

    game.event_close_credit_mobilier!

    expect(game.unstarted_corporation_summary.last).not_to include(game.credit_mobilier)
  end
end
