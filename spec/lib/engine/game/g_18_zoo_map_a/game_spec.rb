# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G18ZOOMapA::Game do
  describe 4 do
    it 'corporation should earn 2$N for each share in Market' do
      game = fixture_at_action(14, clear_cache: true)

      corporation = game.corporation_by_id('GI')
      action = {
        'type' => 'pass',
        'entity' => 'Player 1',
        'entity_type' => 'player',
      }
      expect(corporation.cash).to eq(28)
      expect(game.log.index { |item| item.message == 'GI earns 4$N (2 certs in the Market)' }).to be_nil

      game.process_action(action)

      expect(corporation.cash).to eq(32)
      expect(game.log.index { |item| item.message == 'GI earns 4$N (2 certs in the Market)' }).to be_truthy
    end
  end

  describe 5 do
    it 'log messages after buy / pass / sell' do
      game = fixture_at_action(10)

      expect(game.log.index { |item| item.action_id == 7 }).to be_nil # Buy, Pass
      expect(game.log.find { |item| item.action_id == 8 }.message).to eq('Player 1 passes') # Pass
      expect(game.log.find { |item| item.action_id == 10 }.message).to eq('Player 2 declines to buy shares') # Pass
    end
  end

  describe 17 do
    it 'whatsup cannot be used if corporation already own maximum number of trains' do
      game = fixture_at_action(23, clear_cache: true)

      action = {
        'type' => 'choose_ability',
        'entity' => 'WHATSUP',
        'entity_type' => 'company',
        'choice' => {
          'type' => 'whatsup',
          'corporation_id' => 'GI',
          'train_id' => '3S-2',
        },
      }
      expect(game.exception).to be_nil
      expect(game.process_action(action).exception).to be_a(Engine::GameError)
    end
  end

  describe 18 do
    it 'buying a new train after whatsup (on first train on new phase) must not give "new-phase" bonus' do
      game = fixture_at_action(26, clear_cache: true)

      corporation = game.corporation_by_id('GI')
      action = {
        'type' => 'buy_train',
        'entity' => 'GI',
        'entity_type' => 'corporation',
        'train' => '3S-1',
        'price' => 12,
        'variant' => '3S',
      }
      expect(corporation.share_price.price).to eq(7)
      game.process_action(action)
      expect(corporation.share_price.price).to eq(8)
    end
  end
end
