# frozen_string_literal: true

require 'spec_helper'
require_relative 'system_context'

module Engine
  describe Game::G1832::Game do
    let(:game) { Game::G1832::Game.new(%w[a b c]) }

    describe 'forming a system' do
      include_context 'with a system formed from ACL and SALR'

      it 'pars the system at the average of the two companies\' share prices' do
        expect(system.par_price.price).to eq(100)
        expect(system.share_price.price).to eq(100)
        expect(system.share_price.corporations).to include(system)
      end

      it 'makes the player with the most of the system its president' do
        expect(system.owner).to eq(player_a)
      end
    end
  end
end
