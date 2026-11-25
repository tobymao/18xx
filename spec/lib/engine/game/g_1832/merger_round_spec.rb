# frozen_string_literal: true

require 'spec_helper'

module Engine
  describe Game::G1832::Game do
    let(:optional_rules) { [] }
    let(:game) { Game::G1832::Game.new(%w[a b c], optional_rules: optional_rules) }

    def advance_to_phase(name)
      game.phase.next! until game.phase.name == name
    end

    # Leave the initial auction for the first stock round.
    def start_stock_round
      game.send(:next_round!)
      expect(game.round).to be_a(Engine::Round::Stock)
    end

    describe 'the rounds after a stock round' do
      it 'goes to an operating round while mergers are not allowed' do
        start_stock_round
        advance_to_phase('3')

        game.send(:next_round!)

        expect(game.round).to be_a(Engine::Round::Operating)
      end

      it 'goes to a merger and takeover round once mergers are allowed' do
        start_stock_round
        advance_to_phase('4')

        game.send(:next_round!)

        expect(game.round).to be_a(Game::G1832::Round::Merger)
        expect(game.log.map(&:message)).to include(a_string_matching(/Merger and Takeover Round/))
      end

      it 'then goes to the operating round' do
        start_stock_round
        advance_to_phase('4')
        game.send(:next_round!)

        game.send(:next_round!)

        expect(game.round).to be_a(Engine::Round::Operating)
        expect(game.round.round_num).to eq(1)
      end

      it 'runs the operating rounds and returns to a stock round, as before' do
        start_stock_round
        advance_to_phase('3')
        game.send(:next_round!)
        operating_rounds = game.instance_variable_get(:@operating_rounds)

        (operating_rounds - 1).times do
          game.send(:next_round!)
          expect(game.round).to be_a(Engine::Round::Operating)
        end
        game.send(:next_round!)

        expect(game.round).to be_a(Engine::Round::Stock)
      end

      context 'with the no mergers option' do
        let(:optional_rules) { [:no_mergers] }

        it 'never holds a merger round' do
          start_stock_round
          advance_to_phase('4')

          game.send(:next_round!)

          expect(game.mergers_allowed?).to be(false)
          expect(game.round).to be_a(Engine::Round::Operating)
        end
      end
    end
  end
end
