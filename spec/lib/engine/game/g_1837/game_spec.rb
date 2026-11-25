# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1837::Game do
  describe '1837_game_end_bank' do
    it 'names the operating round that follows the exchange round' do
      game = fixture_at_action(821)

      expect(game.round).to be_a(Engine::Game::G1837::Round::Exchange)
      expect(game.round_description('Exchange')).to eq('Exchange Round before Operating Round 8.2')
    end

    it 'names the stock round that follows the exchange round' do
      game = fixture_at_action(875)

      expect(game.round).to be_a(Engine::Game::G1837::Round::Exchange)
      expect(game.round_description('Exchange')).to eq('Exchange Round before Stock Round 9')
    end
  end
end
