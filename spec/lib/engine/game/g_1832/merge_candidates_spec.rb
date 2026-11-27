# frozen_string_literal: true

require 'spec_helper'

module Engine
  describe Game::G1832::Game do
    let(:game) { Game::G1832::Game.new(%w[a b c]) }

    describe 'systems and the corporations that can merge' do
      it 'offers every unformed system for formation' do
        expect(game.available_systems.map(&:id)).to contain_exactly(*%w[AMTK BNSF IC CSX NS])
      end

      it 'only offers a system that has not been formed' do
        game.corporation_by_id('AMTK').floated = true

        expect(game.available_systems.map(&:id)).not_to include('AMTK')
      end

      it 'does not treat a floated system as a company that can be merged' do
        game.corporations.each { |corp| corp.floated = true }

        expect(game.merge_corporations.none? { |corp| game.system?(corp) }).to be(true)
        expect(game.merge_corporations).not_to be_empty
      end
    end
  end
end
