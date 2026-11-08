# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE consolidation (§5.1.5, §10.6)' do
  include G18OESpecHelpers

  let(:game) { new_game }

  def consolidation!(holdings)
    allow(game).to receive(:major_phase?).and_return(true)
    game.instance_variable_set(:@turn, 2)
    holdings.each_with_index do |ids, index|
      ids.each { |id| start_regional!(game, id, game.players[index]) }
    end
    enter_round!(game, game.new_consolidation_round)
  end

  def own_regional(player)
    game.corporations.find { |c| c.type == :regional && c.president?(player) }
  end

  it 'is triggered by the first level 5 train' do
    expect(game.depot.upcoming.find { |t| t.name == '5' }.events).to eq([{ 'type' => 'consolidation_triggered' }])
  end

  it 'replaces the stock round after the operating round set ends' do
    start_regional!(game, 'LNWR', game.players.first)
    game.event_consolidation_triggered!
    enter_round!(game, game.operating_round(1))
    game.instance_variable_set(:@operating_rounds, 2)

    game.next_round!
    expect(game.round).to be_a(Engine::Round::G18OE::Operating)

    game.next_round!
    expect(game.round).to be_a(Engine::Round::G18OE::Consolidation)
  end

  it 'does not let a regional president pass' do
    round = consolidation!([%w[LNWR], %w[PLM], %w[SFAI]])
    player = round.current_entity

    expect(round.active_step.actions(player)).not_to include('pass')
    expect(round.active_step.actions(own_regional(player))).to include('convert')
  end

  it 'does not let a regional pass for its president' do
    round = consolidation!([%w[LNWR], %w[PLM], %w[SFAI]])
    regional = own_regional(round.current_entity)

    expect(round.active_step.actions(regional)).to include('convert')
    expect(round.active_step.actions(regional)).not_to include('pass')
  end

  it 'keeps a broke regional president blocking until they convert (§5.1.5)' do
    allow(game).to receive(:removable_regional?).and_return(false)
    round = consolidation!([%w[LNWR], %w[PLM], %w[SFAI]])
    president = round.current_entity
    game.players.each { |p| p.set_cash(0, game.bank) }
    round.skip_steps

    expect(president.passed?).to be_falsey
    expect(round.active_step.actions(own_regional(president))).to include('convert')
    expect(round.actions_for(own_regional(president))).to include('convert')
  end

  it 'converts a regional into a major' do
    round = consolidation!([%w[LNWR], %w[PLM], %w[SFAI]])

    expect(convert!(round, own_regional(round.current_entity)).type).to eq(:major)
  end

  it 'lets players pass once their regionals are gone' do
    round = consolidation!([%w[LNWR], %w[PLM], %w[SFAI]])
    convert!(round, own_regional(round.current_entity)) while own_regional(round.current_entity)

    expect(game.players.map { |p| own_regional(p) }).to all(be_nil)
    expect(round.active_step.actions(round.current_entity)).to include('pass')
  end

  it 'lets a regional president end the turn after selling (§10)' do
    round = consolidation!([%w[LNWR GWR], %w[PLM], %w[SFAI]])
    seller = round.current_entity
    major = convert!(round, game.corporation_by_id('LNWR'))
    convert!(round, own_regional(round.current_entity)) until round.current_entity == seller
    share = seller.shares_of(major).reject(&:president).first
    act!(round, Engine::Action::SellShares.new(seller, shares: [share], percent: share.percent))

    expect(own_regional(seller)).not_to be_nil
    expect(round.active_step.actions(seller)).to include('pass')
  end

  it 'is followed by operating rounds in the same turn' do
    consolidation!([%w[LNWR], %w[PLM], %w[SFAI]])
    turn = game.turn
    game.next_round!

    expect(game.round).to be_a(Engine::Round::G18OE::Operating)
    expect(game.turn).to eq(turn)
    expect(game.consolidation_complete).to be(true)
  end

  describe 'a player owning a minor (§5.1.5, §10.6)' do
    let(:round) { consolidation!([[], [], []]) }
    let(:owner) { round.current_entity }
    let(:rival) { game.players[1] }
    let(:step) { round.active_step }
    let!(:minor) do
      round
      start_minor!(game, 'B', owner, 'SP')
    end

    before { game.phase.next! }

    def own_major!
      start_major!(game, 'PLM', owner)
    end

    def rival_major!
      start_major!(game, 'LNWR', rival)
    end

    def offer!(choice)
      act!(round, Engine::Action::Choose.new(owner, choice: choice, target: minor))
    end

    it 'blocks pass while the player owns any minor (§5.1.5)' do
      rival_major!
      expect(step.actions(owner)).to include('buy_shares')
      expect(step.actions(owner)).not_to include('pass')
    end

    it 'lets the player end their turn after acting' do
      major = rival_major!
      take_treasury_shares!(game, owner, major, 1)
      share = owner.shares_of(major).reject(&:president).first
      act!(round, Engine::Action::SellShares.new(owner, shares: [share], percent: share.percent))
      expect(round.current_actions).not_to be_empty
      expect(step.actions(owner)).to include('pass')
    end

    it 'keeps Offer reachable over the certificate limit with nothing to sell (§5.1.5)' do
      allow(game).to receive(:cert_limit).and_return(0)
      expect(step.actions(owner)).to include('choose')
      expect(step.entity_choices(minor)).to eq('offer_or_abandon' => 'Offer')
    end

    it 'keeps Merge reachable over the certificate limit (§10.6)' do
      own_major!
      allow(game).to receive(:cert_limit).and_return(0)
      expect(step.can_merge?(owner, minor)).to be(true)
      act!(round, Engine::Action::Choose.new(owner, choice: minor.id))
      expect(round.merge_minor).to eq(minor)
    end

    it 'makes an owner over the certificate limit sell first when they can (§4.1)' do
      major = rival_major!
      take_treasury_shares!(game, owner, major, 1)
      allow(game).to receive(:cert_limit).and_return(0)
      expect(step.actions(owner)).to include('sell_shares')
      expect(step.actions(owner)).not_to include('choose')
    end

    it 'shows Merge and Offer when the owner can merge and a major can be asked (§10.6)' do
      own_major!
      rival_major!
      expect(step.can_merge?(owner, minor)).to be(true)
      expect(step.entity_choices(minor)).to eq('offer_or_merge' => 'Offer')
    end

    it 'shows only Merge when the owner can merge and nobody is left to ask' do
      own_major!
      expect(step.can_merge?(owner, minor)).to be(true)
      expect(step.entity_choices(minor)).to eq({})
    end

    it 'shows Offer when the owner cannot merge, even with nobody to ask' do
      expect(step.entity_choices(minor)).to eq('offer_or_abandon' => 'Offer')
    end

    it 'shows no Offer for an unmergeable minor while the owner presides a regional' do
      start_regional!(game, 'SB', owner)
      expect(step.entity_choices(minor)).to eq({})
    end

    it 'shows no Offer once the owner has acted' do
      round.current_actions << Engine::Action::Choose.new(owner, choice: 'offer_or_merge', target: minor)
      expect(step.entity_choices(minor)).to eq({})
    end

    context 'with a major that has no treasury share' do
      before do
        major = own_major!
        major.treasury_shares.count { |share| !share.president }.times { take_treasury_shares!(game, owner, major, 1) }
      end

      it 'treats a connected no-share major as a merge option' do
        allow(game).to receive(:merge_connected?).and_return(true)
        expect(step.entity_choices(minor)).to eq({})
      end

      it 'treats an unconnected no-share major as no merge option' do
        allow(game).to receive(:merge_connected?).and_return(false)
        expect(step.entity_choices(minor)).to eq('offer_or_abandon' => 'Offer')
      end

      it 'abandons from a recorded offer_or_abandon while loading even though merge_targets over-reports' do
        game.instance_variable_set(:@loading, true)
        expect(game).not_to receive(:merge_graph)
        expect(game.merge_targets(owner, minor)).not_to be_empty
        expect(step.actions(owner)).to include('choose')
        offer!('offer_or_abandon')
        expect(game.abandoned_minor?(minor)).to be(true)
      end
    end

    it 'rejects a plain Offer when the owner cannot merge' do
      expect { offer!('offer_or_merge') }.to raise_error(Engine::GameError, /Cannot offer/)
    end

    it 'rejects an offer_or_abandon when the owner can merge' do
      own_major!
      expect { offer!('offer_or_abandon') }.to raise_error(Engine::GameError, /Cannot offer_or_abandon/)
    end

    it 'rejects an Offer on a minor owned by another player' do
      other = start_minor!(game, 'C', rival, 'SP')
      expect { act!(round, Engine::Action::Choose.new(owner, choice: 'offer_or_abandon', target: other)) }
        .to raise_error(Engine::GameError, /Cannot offer/)
    end
  end
end
