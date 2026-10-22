# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE spec driver' do
  include G18OESpecHelpers

  it 'reaches OR1 with 12 minors and 18 regionals floated' do
    game = game_at_or1

    expect(game.round).to be_a(Engine::Round::G18OE::Operating)
    expect(game.minor_regional_order.size).to eq(30)
    expect(game.major_phase?).to be(true)
  end

  it 'buys all 30 reserved 2+2 trains in OR1' do
    game = finish_or!(game_at_or1)

    expect(game.depot.upcoming.count { |t| t.name == '2+2' }).to eq(0)
  end

  it 'reaches the second stock round' do
    game = game_at_sr2

    expect(game.round).to be_a(Engine::Round::Stock)
    expect(game.turn).to eq(2)
  end

  it 'works for 4 players with another seed' do
    game = game_at_or1(players: %w[a b c d], seed: 7)

    expect(game.round).to be_a(Engine::Round::G18OE::Operating)
  end

  it 'works for 7 players' do
    game = finish_or!(game_at_or1(players: %w[a b c d e f g]))

    expect(game.round).to be_a(Engine::Round::G18OE::Operating)
    expect(game.round.round_num).to eq(2)
  end

  it 'does not share depots between games' do
    expect(new_game.depot).not_to equal(new_game.depot)
  end
end
