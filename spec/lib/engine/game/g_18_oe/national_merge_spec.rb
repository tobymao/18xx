# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE merging a minor into a national (§10.5)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:round) { stock_round!(game) }
  let(:step) { round.active_step }
  let(:player) { round.current_entity }
  let(:national) do
    major = start_major!(game, 'LNWR', player)
    game.form_national!(major)
    major
  end
  let(:minor) { start_minor!(game, 'B', player, 'SP') }

  before do
    allow(game).to receive(:major_phase?).and_return(true)
    game.phase.next! until game.phase.name == '4'
  end

  def merge!(target = national, from: round, merging: minor)
    act!(from, Engine::Action::Choose.new(from.current_entity, choice: merging.id))
    act!(from, Engine::Action::Merge.new(merging, corporation: target))
  end

  def empty_open_market!
    shares = game.share_pool.shares_by_corporation[national].dup
    shares.each_with_index do |share, index|
      game.share_pool.transfer_shares(share.to_bundle, game.players[index % game.players.size])
    end
  end

  def place_minor_token!(hex_id, index = 0)
    city = game.hex_by_id(hex_id).tile.cities[index]
    city.place_token(minor, minor.next_token, free: true, check_tokenable: false)
    city
  end

  it 'lists a national the player presides as a target (§10.5)' do
    national
    expect(game.merge_targets(player, minor)).to eq([national])
  end

  it 'does not list a national presided by another player (§10.5)' do
    other = start_major!(game, 'GWR', game.players.last)
    game.form_national!(other)
    national
    expect(game.merge_targets(player, minor)).to eq([national])
  end

  it 'lists a national only once per Stock Round (§10.5)' do
    national
    round.merged_majors << national
    expect(game.merge_targets(player, minor)).to be_empty
  end

  it 'gives the owner an Open Market share and forfeits the minor cash to the bank (§10.5)' do
    national
    minor
    expect(game.merge_share(national).owner).to eq(game.share_pool)
    cash_before = national.cash
    bank_before = game.bank.cash
    expect { merge! }.to change { player.num_shares_of(national) }.by(1)
    expect(national.cash).to eq(cash_before)
    expect(game.bank.cash).to eq(bank_before + 120)
    expect(minor.cash).to eq(0)
  end

  context 'with no stock in the Open Market' do
    before do
      national
      empty_open_market!
    end

    it 'is a target when a minor token is in a home-zone city (§10.5)' do
      place_minor_token!('G26')
      expect(game.merge_targets(player, minor)).to eq([national])
    end

    it 'is not a target without any minor token (§10.5)' do
      minor
      expect(game.merge_targets(player, minor)).to be_empty
    end

    it 'is a target when track joins a minor token to a home-zone city (§10.5)' do
      place_minor_token!('N31')
      expect(game.merge_targets(player, minor)).to eq([national])
    end

    it 'is not a target without that connection (§10.5)' do
      place_minor_token!('Q38')
      expect(game.merge_targets(player, minor)).to be_empty
    end

    it 'merges with no share for the owner and the minor cash to the bank (§10.5)' do
      place_minor_token!('G26')
      cash_before = national.cash
      bank_before = game.bank.cash
      expect { merge! }.not_to(change { player.num_shares_of(national) })
      expect(national.cash).to eq(cash_before)
      expect(game.bank.cash).to eq(bank_before + 120)
    end
  end

  describe 'trains' do
    let(:train) { game.depot.upcoming.first }

    before do
      national
      game.buy_train(minor, train, :free)
    end

    it 'moves the minor trains to the national (§10.5)' do
      merge!
      expect(train.owner).to eq(national)
      expect(round.active_step).to be_a(Engine::Game::G18OE::Step::MergeDiscardTrain)
      expect(round.active_step.active_entities).to eq([national])
    end

    it 'lets the national decline a minor train to the Open Market (§10.5)' do
      merge!
      act!(round, Engine::Action::DiscardTrain.new(national, train: train))
      expect(game.depot.discarded).to include(train)
      expect(game.rusted_trains).not_to include(train)
    end

    it 'forces a discard down to the national train limit (§10.5)' do
      limit = game.train_limit(national)
      limit.times { game.buy_train(national, game.depot.upcoming.first, :free) }
      merge!
      expect(national.trains.size).to eq(limit + 1)
      expect(round.active_step).to be_a(Engine::Step::DiscardTrain)
      act!(round, Engine::Action::DiscardTrain.new(national, train: train))
      expect(national.trains.size).to eq(limit)
      expect(round.active_step).not_to be_a(Engine::Step::DiscardTrain)
    end

    it 'lets the national discard its own rusted train to the Locomotive Works (§10.5)' do
      own = game.depot.upcoming.first
      game.buy_train(national, own, :free)
      own.rusted = true
      merge!
      act!(round, Engine::Action::DiscardTrain.new(national, train: own))
      expect(game.rusted_trains).to include(own)
    end
  end

  describe 'abandonment' do
    let(:minor) { start_minor!(game, 'G', player, 'SP') }

    before do
      national
      place_minor_token!('Q38')
      merge!
    end

    it 'abandons the minor (§10.5, §9.5)' do
      expect(game.abandoned_minor?(minor)).to be(true)
      expect(minor.owner).to be_nil
      expect(minor).not_to be_closed
      expect(game.minor_regional_order).not_to include(minor)
      expect(minor.placed_tokens).to be_empty
    end

    it 'records no charter, pending acquisition or token step (§10.5)' do
      expect(game.merged_minors[national]).to be_empty
      expect(round.pending_acquisition).to be_nil
      expect(round.active_step).not_to be_a(Engine::Game::G18OE::Step::MergeToken)
    end

    it 'leaves the special ability on the minor charter (§10.5 majors only)' do
      expect(minor.abilities).not_to be_empty
      expect(national.abilities).to be_empty
    end
  end

  it 'keeps the K mail contract with K (§10.5)' do
    national
    k = start_minor!(game, 'K', player, 'SP')
    mail = k.companies.dup
    expect(mail).not_to be_empty
    merge!(merging: k)
    expect(k.companies).to eq(mail)
    expect(national.companies).to be_empty
  end

  it 'pays no minor A bonus to a national (§15.1)' do
    national
    a = start_minor!(game, 'A', player, 'SP')
    cash_before = national.cash
    merge!(merging: a)
    expect(national.cash).to eq(cash_before)
  end

  it 'sends the Pullman of M to the Open Market (R40)' do
    national
    m = start_minor!(game, 'M', player, 'SP')
    card = game.depot.upcoming.find { |t| game.pullman?(t) }
    game.buy_train(m, card, :free)
    merge!(merging: m)
    expect(game.pullman(national)).to be_nil
    expect(game.pullman(m)).to be_nil
    expect(game.depot.discarded).to include(card)
    expect(game.log.map(&:message)).to include("#{national.name} discards its Pullman to the Open Market")
  end

  it 'tells the Consolidation round to merge into a national (§10.6)' do
    national
    minor
    consolidation = enter_round!(game, game.new_consolidation_round)
    expect(consolidation.active_step.help).to include('Merge into one of their majors or nationals: B')
  end

  it 'offers the skip action for a no-share national while loading (§10.5)' do
    national
    empty_open_market!
    place_minor_token!('Q38')
    %i[can_buy_any? can_ipo_any? can_float_minor? can_sell_any? can_remove_any_corporation? can_reserve_any?
       can_convert_any?].each { |name| allow(step).to receive(name).and_return(false) }
    allow(step).to receive(:purchasable_companies).and_return([])
    allow(step).to receive(:buyable_bank_owned_companies).and_return([])
    allow(step).to receive(:must_sell?).and_return(false)
    game.instance_variable_set(:@loading, true)
    expect(game).not_to receive(:merge_connected?)
    expect(step.actions(player)).to eq(%w[choose pass skip])
  end

  it 'names nationals in the merge prompt' do
    national
    act!(round, Engine::Action::Choose.new(player, choice: minor.id))
    expect(round.active_step.description).to eq('Merge B into a major or national')
    expect(round.active_step.mergeable_type(minor)).to eq('Majors and nationals that can absorb B')
  end
end
