# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1861::Game do
  describe 167_259 do
    it 'majors are nationalised in operating order' do
      game = fixture_at_action(582)

      # MKN should be the first to be potentially nationalised.
      corporation = game.corporation_by_id('MKN')
      expect(game.current_entity).to eq(corporation)
    end

    it 'minors are nationalised in operating order' do
      game = fixture_at_action(673)

      # Checking RSR token locations and order tells us if the minors
      # have been nationalised in the correct order.
      hexes = game.corporation_by_id('RSR').placed_tokens.map(&:hex).map(&:coordinates)
      expect(hexes).to eq(%w[E1 D14 D20 K17 I19 H8 B4 E9])
    end
  end

  describe 'bank_breaks_then_final_phase' do
    it 'has no game_end_trigger before the bank breaks' do
      game = fixture_at_action(673)

      expect(game.finished).to eq(false)
      expect(game.bank.broken?).to eq(false)
      expect(game.game_end_trigger).to be_nil
      expect(game.game_end_reason).to be_nil
      expect(game.game_ending_description).to be_nil
      expect(game.instance_variable_get(:@final_turn)).to eq(nil)
    end

    it 'when the bank breaks, :bank is the game_end_trigger' do
      game = fixture_at_action(674)

      expect(game.finished).to eq(false)
      expect(game.bank.broken?).to eq(true)
      expect(game.game_end_trigger).to eq(%i[bank current_or])
      expect(game.game_end_reason).to be_nil
      expect(game.game_ending_description).to eq('Bank Broken : Game Ends at conclusion of this OR (7.2)')
      # @final_turn gets set only when timing is :one_more_full_or_set
      expect(game.instance_variable_get(:@final_turn)).to eq(nil)
    end

    it 'when phase 8 is reached, the game is extended and :bank is no longer the game_end_trigger' do
      game = fixture_at_action(675)

      expect(game.finished).to eq(false)
      expect(game.bank.broken?).to eq(true)
      expect(game.game_end_trigger).to eq(%i[final_phase one_more_full_or_set])
      expect(game.game_end_reason).to be_nil
      expect(game.game_ending_description).to eq('Final phase was reached : Game Ends at conclusion of OR 8.3')
      expect(game.instance_variable_get(:@final_turn)).to eq(8)
    end

    it '@game_end_reason is :final_phase' do
      game = fixture_at_action(780)

      expect(game.finished).to eq(true)
      expect(game.bank.broken?).to eq(true)
      expect(game.game_end_trigger).to eq(%i[final_phase one_more_full_or_set])
      expect(game.game_end_reason).to eq(:final_phase)
      expect(game.game_ending_description).to eq('Final phase was reached')
      expect(game.instance_variable_get(:@final_turn)).to eq(8)
    end
  end
end
