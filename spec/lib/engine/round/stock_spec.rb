# frozen_string_literal: true

require './spec/spec_helper'

require 'engine/game/g_1889'
require 'engine/phase'
require 'engine/round/operating'

module Engine
  describe Round::Stock do
    let(:players) { %w[a b c d e f] }
    let(:game) { Game::G1889.new(players) }
    let(:market) { game.stock_market }
    let(:corp_0) { game.corporations[0] }
    let(:corp_1) { game.corporations[1] }
    let(:corp_2) { game.corporations[2] }
    let(:corp_3) { game.corporations[3] }
    let(:player_0) { game.players[0] }
    let(:subject) { Round::Stock.new(game.players, game: game) }

    describe '#can_buy' do
      it 'can buy yellow at limit' do
        player_0.cash = 10_000
        market.set_par(corp_0, market.market[2][4])
        market.set_par(corp_1, market.market[2][4])
        market.set_par(corp_2, market.market[2][4])
        market.set_par(corp_3, market.market[6][0])
        5.times { game.share_pool.buy_share(player_0, corp_0.shares[0]) }
        5.times { game.share_pool.buy_share(player_0, corp_1.shares[0]) }
        1.times { game.share_pool.buy_share(player_0, corp_2.shares[0]) } # at 6-player cert limit
        expect(subject.can_buy?(corp_2.shares[0])).to eq(false)
        expect(subject.can_buy?(corp_3.shares[0])).to eq(true)
      end
    end
  end
end
