# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE consolidation (§5.1.5, §10.6)' do
  include G18OESpecHelpers

  let(:game) { game_at_or1 }

  def consolidation!
    game.event_consolidation_triggered!
    2.times { finish_or!(game) }
    game.players.each { |p| game.bank.spend(2000, p) }
    game
  end

  def own_regional(player)
    game.corporations.find { |c| c.type == :regional && c.president?(player) }
  end

  it 'is triggered by the first level 5 train' do
    expect(game.depot.upcoming.find { |t| t.name == '5' }.events).to eq([{ 'type' => 'consolidation_triggered' }])
  end

  it 'waits for the end of the operating round set' do
    game.event_consolidation_triggered!
    finish_or!(game)
    expect(game.round).to be_a(Engine::Round::G18OE::Operating)

    finish_or!(game)
    expect(game.round).to be_a(Engine::Round::G18OE::Consolidation)
  end

  it 'does not let a regional president pass' do
    consolidation!
    player = game.current_entity

    expect(game.round.active_step.actions(player)).not_to include('pass')
    expect(game.round.active_step.actions(own_regional(player))).to include('convert')
  end

  it 'converts a regional into a major' do
    consolidation!
    regional = convert!(game, own_regional(game.current_entity))

    expect(regional.type).to eq(:major)
  end

  it 'lets players pass once their regionals are gone' do
    consolidation!
    convert!(game, own_regional(game.current_entity)) while own_regional(game.current_entity)

    expect(game.corporations.none? { |c| c.type == :regional }).to be(true)
    expect(game.round.active_step.actions(game.current_entity)).to include('pass')
  end

  it 'is the stock round, so operating rounds follow it' do
    consolidation!
    turn = game.turn
    convert!(game, own_regional(game.current_entity)) while own_regional(game.current_entity)
    finish_sr!(game)

    expect(game.round).to be_a(Engine::Round::G18OE::Operating)
    expect(game.turn).to eq(turn)
    expect(game.consolidation_complete).to be(true)
  end
end
