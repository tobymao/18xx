# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE merging a minor into a major in a Stock Round (§10.5)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:round) { stock_round!(game) }
  let(:step) { round.active_step }
  let(:player) { round.current_entity }
  let(:major) { start_major!(game, 'LNWR', player) }
  let(:minor) { start_minor!(game, 'B', player, 'SP') }

  before do
    allow(game).to receive(:major_phase?).and_return(true)
    game.phase.next!
  end

  it 'offers no merge before Train Phase 3 (§10.5)' do
    fresh = new_game
    r = stock_round!(fresh)
    allow(fresh).to receive(:major_phase?).and_return(true)
    m = start_major!(fresh, 'LNWR', r.current_entity)
    b = start_minor!(fresh, 'B', r.current_entity, 'SP')

    expect(r.active_step.merge_targets(r.current_entity, b)).to be_empty
    expect(r.active_step.actions(r.current_entity)).not_to include('choose')
    expect(m).to be_floated
  end

  it 'offers to merge a minor into a major the player presides from Train Phase 3 (§10.5)' do
    major
    expect(step.merge_targets(player, minor)).to eq([major])
    expect(step.actions(player)).to include('choose')
  end

  it 'lists minors after the share corporations' do
    major
    minor
    types = step.visible_corporations.map(&:type)
    expect(types.drop_while { |t| t != :minor }.uniq).to eq([:minor])
    expect(step.visible_corporations).to include(minor)
  end

  it 'offers no merge into a major presided by another player' do
    start_major!(game, 'LNWR', game.players.last)
    expect(step.merge_targets(player, minor)).to be_empty
  end

  it 'offers no merge when the major has no share in its treasury or the Open Market (§10.5)' do
    take_treasury_shares!(game, player, major, major.treasury_shares.size)
    expect(step.merge_targets(player, minor)).to be_empty
  end

  it 'allows one minor per major per SR (§10.5)' do
    major
    round.merged_majors << major
    expect(step.merge_targets(player, minor)).to be_empty
  end

  it 'offers no merge after another stock action this turn (§10)' do
    take_treasury_shares!(game, player, major, 1)
    act!(round, Engine::Action::SellShares.new(player, shares: [player.shares_of(major).reject(&:president).first], percent: 10))
    expect(step.can_merge?(player, minor)).to be(false)
  end

  it 'still offers the merge after selling that major in an earlier turn (§10.2)' do
    major
    round.players_sold[player][major] = :now
    expect(step.can_merge?(player, minor)).to be(true)
  end

  it 'never sells a minor share' do
    expect(step.can_sell?(player, player.shares_of(minor).first.to_bundle)).to be(false)
  end

  it 'starts the merge with Choose' do
    major
    act!(round, Engine::Action::Choose.new(player, choice: minor.id))
    expect(round.merge_minor).to eq(minor)
  end
end
