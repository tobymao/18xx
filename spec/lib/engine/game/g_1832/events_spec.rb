# frozen_string_literal: true

require 'spec_helper'

module Engine
  describe Game::G1832::Game do
    let(:game) { Game::G1832::Game.new(%w[a b c]) }

    describe 'final merger chance event' do
      it 'is handled when the first 6-train is bought' do
        expect { game.event_final_merger_chance! }.not_to raise_error

        expect(game.final_merger_triggered?).to be(true)
        expect(game.log.last.message).to include('Final merger and takeover opportunity')
      end

      it 'has not happened at the start of the game' do
        expect(game.final_merger_triggered?).to be(false)
      end
    end
  end
end
