# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE ending the game (§13)' do
  include G18OESpecHelpers

  let(:game) { new_game }

  def reach_level_8_in_or!(or_num)
    start_regional!(game, 'LNWR', game.players.first)
    game.instance_variable_set(:@operating_rounds, 2)
    enter_round!(game, game.operating_round(or_num))
    game.after_phase_change('8')
  end

  it 'gives the final turn three ORs when level 8 arrives in the last OR of a set' do
    reach_level_8_in_or!(2)

    expect(game.final_operating_rounds).to eq(3)
  end

  it 'keeps two final ORs when level 8 arrives in the first OR of a set' do
    reach_level_8_in_or!(1)

    expect(game.final_operating_rounds).to eq(2)
  end

  it 'plays the extended final set before the next stock round' do
    reach_level_8_in_or!(2)
    enter_round!(game, game.stock_round)
    game.instance_variable_set(:@final_turn, game.turn)

    round_nums = Array.new(3) do
      game.next_round!
      expect(game.round).to be_a(Engine::Round::G18OE::Operating)
      game.round.round_num
    end

    expect(round_nums).to eq([1, 2, 3])
  end

  it 'returns to a stock round after two ORs when the final set is not extended' do
    start_regional!(game, 'LNWR', game.players.first)
    game.instance_variable_set(:@operating_rounds, 2)
    enter_round!(game, game.operating_round(2))

    game.next_round!

    expect(game.round).to be_a(Engine::Round::Stock)
  end

  it 'adds the remainder cash once, on the first level 8 train' do
    bank = game.bank.cash
    2.times { game.event_remainder_cash_added! }

    expect(game.bank.cash - bank).to eq(100_000)
    expect(game.depot.upcoming.find { |t| t.name == '8+8' }.events).to eq([{ 'type' => 'remainder_cash_added' }])
  end

  it 'ends after the current OR on a bank break and after the next full OR set on level 8, never on bankruptcy' do
    expect(Engine::Game::G18OE::Game::GAME_END_CHECK).to eq(bank: :current_or, final_phase: :one_more_full_or_set)
  end
end
