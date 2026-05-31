# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1822Africa::Game do
  # Both triggers fire: bid boxes empty first, then a company hits max stock value.
  # Game ends at conclusion of the current OR (stock market takes precedence).
  describe '1822Africa_game_end_both' do
    it 'game end has not been triggered' do
      game = fixture_at_action(208)

      expect(game.bidbox.length).to be >= 3
      expect(game.stock_market.max_reached?).to be_falsy
      expect(game.game_end_trigger).to be_nil
      expect(game.game_ending_description).to be_nil
      expect(game.finished).to be false
      expect(game.game_end_reason).to be_nil
    end

    it 'game end triggered by empty bid box' do
      game = fixture_at_action(209)

      expect(game.bidbox.length).to be < 3
      expect(game.stock_market.max_reached?).to be_falsy
      expect(game.game_end_trigger).to eq(%i[bid_boxes full_or])
      expect(game.game_ending_description).to eq('Cannot refill bid boxes : Game Ends at conclusion of OR 5.2')
      expect(game.finished).to be false
      expect(game.game_end_reason).to be_nil
    end

    it 'game end triggered by stock market price' do
      game = fixture_at_action(237)

      expect(game.stock_market.max_reached?).to be true
      expect(game.game_end_trigger).to eq(%i[stock_market current_or])
      expect(game.game_ending_description).to eq('Company hit max stock value : Game Ends at conclusion of this OR (5.2)')
      expect(game.finished).to be false
      expect(game.game_end_reason).to be_nil
    end

    it 'game finished and @game_end_reason is :stock_market' do
      game = fixture_at_action(246)

      expect(game.stock_market.max_reached?).to be true
      expect(game.game_end_trigger).to eq(%i[stock_market current_or])
      expect(game.game_ending_description).to eq('Company hit max stock value')
      expect(game.finished).to be true
      expect(game.game_end_reason).to eq(:stock_market)
    end
  end

  # Only the bid boxes trigger fires; the game runs to the end of the scheduled OR.
  describe '1822Africa_game_end_bid_boxes' do
    it 'game end has not been triggered' do
      game = fixture_at_action(208)

      expect(game.bidbox.length).to be >= 3
      expect(game.stock_market.max_reached?).to be_falsy
      expect(game.game_end_trigger).to be_nil
      expect(game.game_ending_description).to be_nil
      expect(game.finished).to be false
      expect(game.game_end_reason).to be_nil
    end

    it 'game end triggered by empty bid box' do
      game = fixture_at_action(209)

      expect(game.bidbox.length).to be < 3
      expect(game.stock_market.max_reached?).to be_falsy
      expect(game.game_end_trigger).to eq(%i[bid_boxes full_or])
      expect(game.game_ending_description).to eq('Cannot refill bid boxes : Game Ends at conclusion of OR 5.2')
      expect(game.finished).to be false
      expect(game.game_end_reason).to be_nil
    end

    it 'game finished and @game_end_reason is :bid_boxes' do
      game = fixture_at_action(243)

      expect(game.game_end_trigger).to eq(%i[bid_boxes full_or])
      expect(game.game_ending_description).to eq('Cannot refill bid boxes')
      expect(game.finished).to be true
      expect(game.game_end_reason).to eq(:bid_boxes)
    end
  end

  # Only the stock market trigger fires; no bid box shortage occurs.
  describe '1822Africa_game_end_stock_market' do
    it 'game end has not been triggered' do
      game = fixture_at_action(237)

      expect(game.bidbox.length).to be >= 3
      expect(game.stock_market.max_reached?).to be_falsy
      expect(game.game_end_trigger).to be_nil
      expect(game.game_ending_description).to be_nil
      expect(game.finished).to be false
      expect(game.game_end_reason).to be_nil
    end

    it 'game end triggered by stock market price' do
      game = fixture_at_action(238)

      expect(game.stock_market.max_reached?).to be true
      expect(game.game_end_trigger).to eq(%i[stock_market current_or])
      expect(game.game_ending_description).to eq('Company hit max stock value : Game Ends at conclusion of this OR (5.2)')
      expect(game.finished).to be false
      expect(game.game_end_reason).to be_nil
    end

    it 'game finished and @game_end_reason is :stock_market' do
      game = fixture_at_action(245)

      expect(game.stock_market.max_reached?).to be true
      expect(game.game_end_trigger).to eq(%i[stock_market current_or])
      expect(game.game_ending_description).to eq('Company hit max stock value')
      expect(game.finished).to be true
      expect(game.game_end_reason).to eq(:stock_market)
    end
  end
end
