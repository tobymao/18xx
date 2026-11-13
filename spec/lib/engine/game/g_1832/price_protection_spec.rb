# frozen_string_literal: true

require 'spec_helper'

module Engine
  describe Game::G1832::Game do
    let(:game) { Game::G1832::Game.new(%w[a b c]) }

    describe 'certificate count while price protecting' do
      let(:player) { game.players.first }
      let(:corporation) { game.corporation_by_id('ACL') }

      # A price that counts toward the certificate limit, one step above one that does not.
      let(:price_above_limit_zone) do
        game.stock_market.market.flatten.compact.find do |space|
          corporation.share_price = space
          space.counts_for_limit && !game.stock_market.find_share_price(corporation, [:down]).counts_for_limit
        end
      end

      before do
        corporation.ipoed = true
        game.par_corporation(corporation, price_above_limit_zone)
        game.share_pool.buy_shares(player, ShareBundle.new([corporation.presidents_share]), exchange: :free)
        game.sell_queue << [ShareBundle.new([corporation.presidents_share]), player]
      end

      it 'does not count shares that are about to drop out of the limit zone' do
        expect(game.num_certs(player)).to eq(0)
      end

      it 'counts them while price protecting, since protecting keeps them in the zone' do
        expect(game.num_certs(player, price_protecting: true)).to eq(1)
      end
    end
  end
end
