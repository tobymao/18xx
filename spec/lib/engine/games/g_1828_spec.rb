# frozen_string_literal: true

require './spec/spec_helper'
require 'engine/game/g_1828'

module Engine
  describe Game::G1828 do
    context 'par prices' do
      let(:players) { %w[a b c] }
      let(:game) { Game::G1828.new(players) }
      let(:phase) { game.phase }
      let(:corporation) { game.corporations.first }
      subject { game.stock_market }

      it 'should be unlocked by game phase' do
        expect(subject.par_prices.size).to eq(3)
        expect(subject.par_prices.map(&:price)).to include(67, 71, 79)

        phase.buying_train!(corporation, game.trains.find { |t| t.name == '3' })
        expect(subject.par_prices.size).to eq(5)
        expect(subject.par_prices.map(&:price)).to include(67, 71, 79, 86, 94)

        phase.buying_train!(corporation, game.trains.find { |t| t.name == '5' })
        expect(subject.par_prices.size).to eq(6)
        expect(subject.par_prices.map(&:price)).to include(67, 71, 79, 86, 94, 105)

        phase.buying_train!(corporation, game.trains.find { |t| t.name == '3+D' })
        expect(subject.par_prices.size).to eq(7)
        expect(subject.par_prices.map(&:price)).to include(67, 71, 79, 86, 94, 105, 120)
      end
    end
  end
end
