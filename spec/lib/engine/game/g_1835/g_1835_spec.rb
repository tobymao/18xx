# frozen_string_literal: true

require 'spec_helper'
require 'engine/game/g_1835/game'

module Engine
  describe Game::G1835::Game do
    context 'full game' do
      it 'matches the gold master' do
        expect(replay_file('spec/fixtures/1835/full_game.json')).to match_game_state
      end
    end
  end
end