# frozen_string_literal: true

require 'spec_helper'

describe 'G1864 Union Pacific' do
  let(:game) { Engine::Game::G1864::Game.new(%w[alice bob carol], seed: 1) }
  let(:up) { game.union_pacific }

  it 'has eight consist decks covering phases 4 to 8' do
    decks = Engine::Game::G1864::UnionPacific::CONSIST_DECKS

    expect(decks.size).to eq(8)
    decks.each_value do |deck|
      expect(deck.keys).to eq(%w[4 5 6 7 8])
      deck.each_value { |trains| expect(trains).not_to be_empty }
    end
  end

  it 'deals one consist per phase at setup' do
    expect(game.up_consist.keys).to eq(%w[4 5 6 7 8])
  end

  it 'gives the UP its phase trains on reveal, replacing the previous consist' do
    game.reveal_up_consist!('4')
    phase4 = up.trains.map(&:name)
    expect(phase4).to eq(game.up_consist['4'])

    game.reveal_up_consist!('5')
    expect(up.trains.map(&:name)).to eq(game.up_consist['5'])
  end

  it 'does not take consist trains from the depot' do
    before = game.depot.upcoming.size
    game.reveal_up_consist!('4')

    expect(game.depot.upcoming.size).to eq(before)
  end

  it 'holds no cash' do
    expect(up.cash).to eq(0)
  end

  it 'lays track for free' do
    step = Engine::Game::G1864::Step::Track.new(game, [])
    expect(step.tile_cost_spender(up)).to eq(game.bank)
  end

  describe 'tile cost payment' do
    let(:step) { Engine::Game::G1864::Step::Track.new(game, []) }
    let(:hex) { game.hexes.first }
    let(:tile) { hex.tile }

    it 'does not charge the UP for a positive-cost extra lay, and funds Credit Mobilier from the bank' do
      bank_cash = game.bank.cash
      credit_mobilier_cash = game.credit_mobilier.cash

      expect do
        step.pay_tile_cost!(up, tile, 0, hex, up, 20, 0)
      end.not_to raise_error

      expect(up.cash).to eq(0)
      expect(game.credit_mobilier.cash).to eq(credit_mobilier_cash + 20)
      expect(game.bank.cash).to eq(bank_cash - 20)
    end

    it 'does not charge the UP for a terrain cost either' do
      credit_mobilier_cash = game.credit_mobilier.cash

      expect do
        step.pay_tile_cost!(up, tile, 0, hex, up, 40, 0)
      end.not_to raise_error

      expect(up.cash).to eq(0)
      expect(game.credit_mobilier.cash).to eq(credit_mobilier_cash + 40)
    end

    it 'logs the Union Pacific, not the Bank, as the entity laying a paid-for tile' do
      step.pay_tile_cost!(up, tile, 0, hex, up, 20, 0)

      message = game.log.last.message
      expect(message).to start_with('UP')
      expect(message).not_to include('Bank')
      expect(message).not_to include('spends')
    end

    it 'still charges a non-national corporation for its own tile cost, which still funds Credit Mobilier' do
      minor = game.corporations.find { |c| c.type == :minor }
      game.bank.spend(1000, minor)
      minor_cash = minor.cash
      bank_cash = game.bank.cash
      credit_mobilier_cash = game.credit_mobilier.cash

      step.pay_tile_cost!(minor, tile, 0, hex, minor, 20, 0)

      expect(minor.cash).to eq(minor_cash - 20)
      expect(game.credit_mobilier.cash).to eq(credit_mobilier_cash + 20)
      expect(game.bank.cash).to eq(bank_cash)
    end
  end

  it 'always pays a full dividend' do
    step = Engine::Game::G1864::Step::Dividend.new(game, [])
    allow(step).to receive(:current_entity).and_return(up)

    expect(step.payout(up, 300)).to eq(corporation: 0, per_share: 30)
  end

  it 'never buys trains' do
    round = game.operating_round(1)
    step = round.steps.find { |st| st.is_a?(Engine::Game::G1864::Step::BuyTrain) }
    allow(round).to receive(:current_operator).and_return(up)

    expect(step.actions(up)).to eq([])
  end

  describe 'consist reveal' do
    it 'reveals the consist when the phase begins and records it on the UP card' do
      game.after_phase_change('4')

      expect(up.trains.map(&:name)).to eq(game.up_consist['4'])
      description = up.all_abilities.find { |a| a.type == :description }
      expect(description.description).to eq('Train Consist')
      expect(description.desc_detail.lines.map(&:chomp)).to eq([
        "Phase 4: #{game.up_consist['4'].join(', ')} (current)",
        'Phase 5: hidden',
        'Phase 6: hidden',
        'Phase 7: hidden',
        'Phase 8: hidden',
      ])
    end

    it 'shows every consist from the start under the open consists option' do
      open_game = Engine::Game::G1864::Game.new(%w[alice bob carol], seed: 1, optional_rules: [:open_consists])
      detail = open_game.union_pacific.all_abilities.find { |a| a.type == :description }.desc_detail

      expect(detail).not_to include('hidden')
    end

    it 'gives every consist train a unique id that resolves back to the train' do
      game.after_phase_change('4')
      game.after_phase_change('5')
      ids = up.trains.map(&:id)

      expect(ids.uniq.size).to eq(ids.size)
      expect(ids.map { |id| game.train_by_id(id) }).to eq(up.trains)
    end

    it 'still resolves consist trains after the depot rebuilds the train cache' do
      game.after_phase_change('8')
      game.update_trains_cache

      expect(up.trains.map { |train| game.train_by_id(train.id) }).to eq(up.trains)
    end
  end

  describe 'operating start' do
    it 'starts operating in the OR after phase 4 begins, not at the end of the set' do
      game.event_up_operates!
      expect(game.up_operating?).to be(false)

      game.send(:or_round_finished)

      expect(game.up_operating?).to be(true)
    end

    it 'moves one space right instead of operating when it has no President' do
      game.instance_variable_set(:@up_started, true)

      game.operating_round(1).setup
      expect(up.share_price.price).to eq(90)

      game.operating_round(2).setup
      expect(up.share_price.price).to eq(100)
    end

    it 'is skipped entirely and logged when it has no President' do
      game.instance_variable_set(:@up_started, true)
      round = game.operating_round(1)
      round.setup

      expect(round.entities).to include(up)
      expect(round.finished?).to be(true)
      expect(game.log.map(&:message)).to include('UP has no owner and does not operate')
      expect(game.log.map(&:message)).not_to include(a_string_matching(/operates UP/))
    end

    it 'operates when it has a President' do
      game.share_pool.buy_shares(game.players.first, up.shares.first)
      game.instance_variable_set(:@up_started, true)

      round = game.operating_round(1)
      round.setup

      expect(up.share_price.price).to eq(80)
      expect(round.current_entity).to eq(up)
    end
  end

  it 'shows no float information' do
    alice = game.players.first

    expect(up.floated?).to be(true)

    game.share_pool.buy_shares(alice, up.shares.first)

    expect(game.log.map(&:message)).not_to include('UP floats')
  end

  it 'sends money from UP share sales to the Bank' do
    alice = game.players.first
    bank_before = game.bank.cash

    game.share_pool.buy_shares(alice, up.shares.first)

    expect(up.cash).to eq(0)
    expect(game.bank.cash).to eq(bank_before + 80)
  end
end
