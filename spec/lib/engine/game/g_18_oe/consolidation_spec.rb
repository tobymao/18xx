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
end
