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
      let(:route) { Struct.new(:phase, :train, :corporation).new(game.phase, game.depot.trains.first, game.corporations.first) }
      let(:printed_value) { miami_stop.route_revenue(game.phase, route.train) }

      # What the dividend step does when a corporation's routes include Miami.
      def run_with(*stops)
        round.routes = [Struct.new(:stops).new(stops)]
        dividend_step.send(:record_miami_run!)
      end

      def next_round
        game.send(:new_operating_round)
      end

      it 'scores Miami as zero until a corporation has run there' do
        expect(game.phase.status).to include('first_miami_run_is_zero')
        expect(game.miami_scores_zero?).to be(true)
        expect(game.miami_revenue(route, [other_stop, miami_stop])).to eq(-printed_value)
      end

      it 'is still zero after a run that does not reach Miami' do
        run_with(other_stop)
        next_round

        expect(game.miami_has_been_run).to be(false)
        expect(game.miami_scores_zero?).to be(true)
      end

      it 'stays zero for every corporation that runs there in the round it is first reached' do
        run_with(other_stop, miami_stop)

        expect(game.miami_has_been_run).to be(true)
        expect(game.miami_scores_zero?).to be(true)
        expect(game.miami_revenue(route, [other_stop, miami_stop])).to eq(-printed_value)
      end

      it 'pays its printed value from the next round on' do
        run_with(other_stop, miami_stop)
        next_round

        expect(game.miami_scores_zero?).to be(false)
        expect(game.miami_revenue(route, [other_stop, miami_stop])).to eq(0)
      end

      it 'keeps the first round even if later corporations also run there' do
        run_with(other_stop, miami_stop)
        run_with(other_stop, miami_stop)
        expect(game.miami_scores_zero?).to be(true)

        next_round
        run_with(other_stop, miami_stop)

        expect(game.miami_scores_zero?).to be(false)
      end

      it 'pays its printed value once the rule no longer applies, in a later phase' do
        game.phase.next! until game.phase.name == '5'

        expect(game.miami_scores_zero?).to be(false)
      end
    end
  end
end
