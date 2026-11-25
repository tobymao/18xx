# frozen_string_literal: true

require 'spec_helper'
require_relative 'system_context'

module Engine
  describe Game::G1832::Game do
    let(:game) { Game::G1832::Game.new(%w[a b c]) }

    describe 'vice-president certificate left over after a merger' do
      include_context 'with a system formed from ACL and SALR'

      it 'leaves the holder a 10% certificate that counts as one certificate' do
        expect(system.owner).to eq(player_a)
        expect(system.vice_president_certs.map(&:owner)).to eq([player_b])
        expect(player_b.percent_of(system)).to eq(10)
        expect(game.num_certs(player_b)).to eq(1)
      end

      it 'is offered for sale as one 10% certificate, not in halves' do
        act_as(player_b)

        bundles = game.sellable_bundles(player_b, system)

        expect(bundles.map(&:percent)).to eq([10])
        expect(bundles.first.shares).to eq(system.vice_president_certs)
        expect(bundles.first.price).to eq(2 * system.share_price.price)
      end

      context 'when the holder also has 5% shares' do
        before do
          give(player_b, system.ipo_shares.reject(&:president).first(2))
          act_as(player_b)
        end

        let(:vp_cert) { system.vice_president_certs.first }

        def offered
          game.sellable_bundles(player_b, system).map do |bundle|
            [bundle.percent, bundle.shares.include?(vp_cert), bundle.shares.size]
          end
        end

        it 'offers the 5% shares one and two at a time, the VP cert alone, and the VP cert with them' do
          expect(offered).to contain_exactly(
            [5, false, 1], [10, false, 2], # sell 1, sell 2
            [10, true, 1],                 # the VP cert alone
            [15, true, 2], [20, true, 3]   # the VP cert and one or both of the 5% shares
          )
        end

        it 'marks the VP cert as a double certificate, so the sell buttons tell it from two 5% shares' do
          double_cert = ->(bundle) { bundle.shares.any?(&:double_cert) }

          marked = game.sellable_bundles(player_b, system).select(&double_cert).map { |bundle| bundle.shares.include?(vp_cert) }

          expect(vp_cert.double_cert).to be(true)
          expect(marked).to eq([true, true, true]) # the VP cert alone and with one or both 5% shares
          expect(game.sellable_bundles(player_b, system).reject(&double_cert).map(&:percent)).to contain_exactly(5, 10)
        end

        it 'sells the VP cert alone and keeps the 5% shares' do
          bundle = game.sellable_bundles(player_b, system).find { |b| b.shares == [vp_cert] }

          sell(player_b, bundle)

          expect(game.exception).to be_nil
          expect(player_b.shares_of(system).map(&:percent)).to eq([5, 5])
          expect(game.share_pool.shares_of(system)).to eq([vp_cert])
        end

        it 'sells one 5% share and keeps the VP cert' do
          bundle = game.sellable_bundles(player_b, system).find { |b| b.percent == 5 }

          sell(player_b, bundle)

          expect(game.exception).to be_nil
          expect(player_b.shares_of(system).map(&:percent)).to contain_exactly(5, 10)
        end
      end

      it 'sells whole for twice the price of a 5% share and queues two shares for price protection' do
        act_as(player_b)
        cash = player_b.cash
        bundle = game.sellable_bundles(player_b, system).first

        sell(player_b, bundle)

        expect(player_b.cash).to eq(cash + (2 * system.share_price.price))
        expect(player_b.shares_of(system)).to be_empty
        expect(game.num_certs(player_b)).to eq(0)
        expect(game.share_pool.shares_of(system).map(&:percent)).to eq([10])
        queued, = game.sell_queue.first
        expect(queued.percent).to eq(10)
        expect(queued.num_shares).to eq(2)
      end

      it 'is bought from the pool by another player as one 10% certificate' do
        act_as(player_b)
        sell(player_b, game.sellable_bundles(player_b, system).first)
        act_as(player_c)
        cash = player_c.cash
        certs = game.num_certs(player_c)
        pool_bundle = game.bundles_for_corporation(game.share_pool, system).first

        game.process_action(
          Action::BuyShares.new(player_c, shares: pool_bundle.shares, share_price: pool_bundle.share_price,
                                          percent: pool_bundle.percent)
        )

        expect(pool_bundle.percent).to eq(10)
        expect(player_c.shares_of(system).map(&:percent)).to contain_exactly(5, 10)
        expect(player_c.cash).to eq(cash - pool_bundle.price)
        expect(game.num_certs(player_c)).to eq(certs + 1)
      end
    end
  end
end
