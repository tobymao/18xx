# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1822Africa::Game do
  # This fixture has the game end triggered by the bid boxes being empty, but
  # then the end of the game is brought forward by a company entering the end
  # zone of the stock market.
  describe '1822Africa_game_end_both' do
    it 'game end has not been triggered' do
      game = fixture_at_action(572)

      expect(game.bidbox.length).to be >= 3
      expect(game.stock_market.max_reached?).to be_falsy
      expect(game.game_end_trigger).to be_nil
      expect(game.game_ending_description).to be_nil
      expect(game.finished).to be false
      expect(game.game_end_reason).to be_nil
    end

    it 'game end triggered by empty bid box' do
      game = fixture_at_action(573)

      expect(game.bidbox.length).to be < 3
      expect(game.stock_market.max_reached?).to be_falsy
      expect(game.game_end_trigger).to eq(%i[bid_boxes full_or])
      expect(game.game_ending_description).to eq(' : Game Ends at conclusion of OR 6.2')
      expect(game.finished).to be false
      expect(game.game_end_reason).to be_nil
    end

    it 'game end triggered by stock market price' do
      game = fixture_at_action(585)

      expect(game.stock_market.max_reached?).to be true
      expect(game.game_end_trigger).to eq(%i[stock_market current_or])
      expect(game.game_ending_description).to eq('Company hit max stock value : Game Ends at conclusion of this OR (6.1)')
      expect(game.finished).to be false
      expect(game.game_end_reason).to be_nil
    end

    it 'game finished and @game_end_reason is :stock_market' do
      game = fixture_at_action(606)

      expect(game.stock_market.max_reached?).to be true
      expect(game.game_end_trigger).to eq(%i[stock_market current_or])
      expect(game.game_ending_description).to eq('Company hit max stock value')
      expect(game.finished).to be true
      expect(game.game_end_reason).to eq(:stock_market)
    end
  end
end
