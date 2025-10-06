# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1822CaWrs::Game do
  describe '1822CAWRS_game_end_bank' do
    it 'has no game_end_trigger before the bank breaks' do
      game = fixture_at_action(1081)

      expect(game.finished).to eq(false)
      expect(game.bank.broken?).to eq(false)
      expect(game.stock_market.max_reached?).not_to eq(true)
      expect(game.game_end_trigger).to be_nil
      expect(game.game_end_reason).to be_nil
      expect(game.game_ending_description).to be_nil
    end

    it ':bank has priority when it and :stock_market occur on same action' do
      game = fixture_at_action(1082)

      expect(game.finished).to eq(false)
      expect(game.bank.broken?).to eq(true)
      expect(game.stock_market.max_reached?).to eq(true)
      expect(game.game_end_trigger).to eq(%i[bank full_or])
      expect(game.game_end_reason).to be_nil
      expect(game.game_ending_description).to eq('Bank Broken : Game Ends at conclusion of OR 9.2')
    end

    it '@game_end_reason is :bank' do
      game = fixture_at_action(1126)

      expect(game.finished).to eq(true)
      expect(game.bank.broken?).to eq(true)
      expect(game.stock_market.max_reached?).to eq(true)
      expect(game.game_end_trigger).to eq(%i[bank full_or])
      expect(game.game_end_reason).to eq(:bank)
      expect(game.game_ending_description).to eq('Bank Broken')
    end
  end
end
