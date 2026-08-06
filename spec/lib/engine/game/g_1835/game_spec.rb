# frozen_string_literal: true

describe Engine::Game::G1835::Game do
  describe 'full_game_no_laid_tokens_private_use_or_bankruptcy' do
    let(:game) { fixture_at_action(58) }

    it 'makes the player who bought all three BY minors the president even though the BY president was bought last' do
      expect(game.corporation_by_id('BY').president).to be(game.players[0])
    end
  end
end
