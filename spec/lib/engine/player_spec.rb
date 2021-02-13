# frozen_string_literal: true

require './spec/spec_helper'
require 'engine/player'

module Engine
  describe Player do
    let(:game) { Game::G1889.new(%w[a b c]) }
    let(:corporation) { game.corporations.first }
    let(:company) { game.companies.first }
    let(:share_pool) { game.share_pool }
    let(:player) { game.player_by_id('a') }
    let(:market) { game.stock_market }

    describe '#num_certs' do
      it 'privates' do
        expect(game.num_certs(player)).to eq(0)
        player.companies << company
        expect(game.num_certs(player)).to eq(1)
      end

      it 'shares' do
        current_price = market.market[0][0]
        market.set_par(corporation, current_price)
        share_pool.buy_shares(player, corporation.shares[0])
        expect(game.num_certs(player)).to eq(1)
      end

      it 'privates and shares' do
        player.companies << company
        current_price = market.market[0][0]
        market.set_par(corporation, current_price)
        share_pool.buy_shares(player, corporation.shares[0])
        expect(game.num_certs(player)).to eq(2)
      end

      it 'non-limit shares' do
        current_price = market.market[-1][0]
        market.set_par(corporation, current_price)
        share_pool.buy_shares(player, corporation.shares[0])
        expect(game.num_certs(player)).to eq(0)
      end
    end
  end
end
