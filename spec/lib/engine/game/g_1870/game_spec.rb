# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1870::Game do
  describe 'game-end-market-400' do
    it '$400 finish variant: game ends immediately after $400 value reached' do
      game = fixture_at_action(959)
      atsf = game.corporation_by_id('ATSF')

      expect(atsf.share_price.price).to eq(375)
      expect(game.finished).to eq(false)
      expect(game.bank.broken?).to eq(true)
      expect(game.game_end_trigger).to eq(%i[bank full_or])
      expect(game.game_end_reason).to be_nil
      expect(game.game_ending_description).to eq('Bank Broken : Game Ends at conclusion of OR 7.3')

      action = {
        'type' => 'dividend',
        'entity' => 'ATSF',
        'entity_type' => 'corporation',
        'kind' => 'payout',
      }
      game.process_action(action, add_auto_actions: true)

      expect(atsf.share_price.price).to eq(400)
      expect(game.finished).to eq(true)
      expect(game.game_end_trigger).to eq(%i[stock_market immediate])
      expect(game.game_end_reason).to eq(:stock_market)
      expect(game.game_ending_description).to eq('Company hit max stock value')
    end
  end
end
