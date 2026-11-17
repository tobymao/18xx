# frozen_string_literal: true

require 'spec_helper'

module Engine
  describe 'Game::Base#share_price_changed' do
    let(:game) { Engine::Game::G1889::Game.new(%w[a b c]) }
    let(:player) { game.players.first }
    let(:corporation) { game.corporation_by_id('AR') }

    before do
      game.par_corporation(corporation, game.stock_market.par_prices.first)
      game.bank.spend(1000, player)
      2.times { game.share_pool.buy_shares(player, corporation.shares.first) }
      corporation.floated = true
    end

    it 'is called after a share sale with the price before the sale' do
      from = corporation.share_price
      share = player.shares_of(corporation).reject(&:president).first

      expect(game).to receive(:share_price_changed).with(corporation, from)
      game.sell_shares_and_change_price(share.to_bundle)
    end

    it 'is called after the end of a stock round moves the price' do
      from = corporation.share_price
      game.share_pool.transfer_shares(corporation.shares.first.to_bundle, game.share_pool)
      round = game.send(:stock_round)

      expect(game).to receive(:share_price_changed).with(corporation, from)
      round.send(:finish_round)
    end

    it 'is called after a dividend moves the price' do
      from = corporation.share_price
      step = game.operating_round(1).steps.find { |s| s.is_a?(Engine::Step::Dividend) }

      expect(game).to receive(:share_price_changed).with(corporation, from)
      step.change_share_price(corporation, share_direction: :right, share_times: 1)
    end
  end
end
