# frozen_string_literal: true

require 'spec_helper'

module Engine
  describe Game::G1832::Game do
    let(:game) { Game::G1832::Game.new(%w[a b c]) }
    let(:miami_stop) { game.miami_hex.tile.offboards.first }
    let(:other_stop) { game.hex_by_id('H16').tile.cities.first }

    describe 'Miami first-run rule' do
      let(:round) { Struct.new(:routes).new([]) }
      let(:dividend_step) { Game::G1832::Step::Dividend.new(game, round) }

      def run_with(*stops)
        round.routes = [Struct.new(:stops).new(stops)]
        dividend_step.send(:mark_miami_first_run_complete!)
      end

      it 'scores Miami as zero until a corporation has run there' do
        expect(game.phase.status).to include('first_miami_run_is_zero')
        expect(game.miami_scores_zero?).to be(true)
      end

      it 'is still zero after a run that does not reach Miami' do
        run_with(other_stop)

        expect(game.miami_has_been_run).to be(false)
        expect(game.miami_scores_zero?).to be(true)
      end

      it 'pays Miami at its printed value for every later run' do
        run_with(other_stop, miami_stop)

        expect(game.miami_has_been_run).to be(true)
        expect(game.miami_scores_zero?).to be(false)
      end
    end
  end
end
