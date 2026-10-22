# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE ending the game (§13)' do
  include G18OESpecHelpers

  let(:game) { game_at_or1 }

  def enter_phase_8!
    game.phase.next! while game.phase.name != '8'
  end

  it 'finishes the set, plays a SR, then the final two ORs when level 8 arrives in OR1' do
    enter_phase_8!

    expect(ors_until_end!(game)).to eq(%w[1.1 1.2 2.1 2.2])
  end

  it 'finishes the OR, plays a SR, then three ORs when level 8 arrives in OR2' do
    finish_or!(game)
    enter_phase_8!

    expect(ors_until_end!(game)).to eq(%w[1.2 2.1 2.2 2.3])
  end

  it 'ends after the current OR when the bank breaks in an OR' do
    game.bank.break!

    expect(ors_until_end!(game)).to eq(%w[1.1])
  end

  it 'plays one more OR when the bank breaks in a SR' do
    2.times { finish_or!(game) }
    game.bank.break!

    expect(ors_until_end!(game)).to eq(%w[2.1])
  end

  it 'adds the remainder cash once, on the first level 8 train' do
    bank = game.bank.cash
    2.times { game.event_remainder_cash_added! }

    expect(game.bank.cash - bank).to eq(100_000)
    expect(game.depot.upcoming.find { |t| t.name == '8+8' }.events).to eq([{ 'type' => 'remainder_cash_added' }])
  end

  it 'does not end on bankruptcy' do
    expect(Engine::Game::G18OE::Game::GAME_END_CHECK.keys).to eq(%i[bank final_phase])
  end
end
