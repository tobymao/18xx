# frozen_string_literal: true

require './spec/spec_helper'

require 'engine'
require 'engine/game/g_1846'
require 'engine/game/g_1889'
require 'engine/share_pool'
require 'engine/share_price'
require 'engine/player'

module Engine
  describe SharePool do
    let(:game) { Game::G1889.new(%w[a b c]) }
    let(:player_1) { game.player_by_id('a') }
    let(:player_2) { game.player_by_id('b') }
    let(:player_3) { game.player_by_id('c') }
    let(:bank) { game.bank }
    let(:corporation) { game.corporations.first }
    let(:company) { game.companies.first }
    let(:share_price) { SharePrice.from_code('10', 0, 0, []) }
    let(:subject) { game.share_pool }

    before :each do
      game.stock_market.set_par(corporation, share_price)
      game.send(:next_round!)
    end

    describe '#buy_shares' do
      it 'can ipo' do
        subject.buy_shares(player_1, corporation.shares.first)
        expect(corporation.ipoed).to be_truthy
        expect(corporation.floated?).to be_falsey
        expect(player_1.cash).to eq(400)
        expect(player_1.percent_of(corporation)).to eq(20)
        expect(corporation.president?(player_1)).to be_truthy
        expect(corporation.cash).to eq(0)
      end

      it 'can float' do
        corporation.shares.take(4).each do |share|
          subject.buy_shares(player_1, share)
        end
        expect(corporation.ipoed).to be_truthy
        expect(corporation.percent_of(corporation)).to eq(50)
        expect(corporation.floated?).to be_truthy
        expect(corporation.cash).to eq(100)
        expect(player_1.cash).to eq(370)
        expect(player_1.percent_of(corporation)).to eq(50)
        expect(corporation.president?(player_1)).to be_truthy
      end

      it 'can swap presidency' do
        subject.buy_shares(player_1, corporation.shares[0])
        subject.buy_shares(player_2, corporation.shares[1])
        subject.buy_shares(player_2, corporation.shares[2])
        expect(corporation.president?(player_1)).to be_truthy

        subject.buy_shares(player_2, corporation.shares[3])
        expect(corporation.president?(player_2)).to be_truthy
        expect(player_1.percent_of(corporation)).to eq(20)
        expect(player_2.percent_of(corporation)).to eq(30)
        expect(player_1.shares_of(corporation).size).to eq(2)
        expect(player_2.shares_of(corporation).size).to eq(2)

        expect(player_1.cash).to eq(400)
        expect(player_2.cash).to eq(390)
      end

      context 'with exchange' do
        it "doesn't ipo" do
          subject.buy_shares(player_1, corporation.shares[1], exchange: company)
          expect(corporation.ipoed).to be_falsey
          expect(corporation.president?(player_1)).to be_falsey
          expect(player_1.cash).to eq(420)
          expect(player_1.percent_of(corporation)).to eq(10)
        end

        it 'floats' do
          corporation.shares[0..2].dup.each do |share|
            subject.buy_shares(player_1, share)
          end

          expect(corporation.floated?).to be_falsey
          expect(corporation.cash).to eq(0)

          subject.buy_shares(player_1, corporation.shares[0], exchange: company)
          expect(corporation.floated?).to be_truthy
          expect(corporation.cash).to eq(100)
        end
      end
    end

    describe '#sell_share' do
      it 'respects order for president swap' do
        corporation.shares[0..1].dup.each do |share|
          subject.buy_shares(player_2, share)
        end

        corporation.shares[0..2].dup.each do |share|
          subject.buy_shares(player_1, share)
        end

        corporation.shares[0..2].dup.each do |share|
          subject.buy_shares(player_3, share)
        end

        expect(player_1.percent_of(corporation)).to eq(30)
        expect(player_2.percent_of(corporation)).to eq(30)
        expect(player_3.percent_of(corporation)).to eq(30)
        expect(corporation.president?(player_2)).to be_truthy

        subject.sell_shares(ShareBundle.new(player_2.shares))
        expect(corporation.president?(player_3)).to be_truthy
      end

      context 'with 60 40 split' do
        before :each do
          corporation.shares[0..4].dup.each do |share|
            subject.buy_shares(player_1, share)
          end

          corporation.shares.dup.each do |share|
            subject.buy_shares(player_2, share)
          end
        end

        it 'sets up correctly' do
          expect(corporation.president?(player_1)).to be_truthy
          expect(player_1.percent_of(corporation)).to eq(60)
          expect(player_2.percent_of(corporation)).to eq(40)
          expect(player_1.cash).to eq(360)
          expect(player_2.cash).to eq(380)
        end

        it 'should not swap with 1 share' do
          subject.sell_shares(ShareBundle.new(player_1.shares.last))
          expect(corporation.president?(player_1)).to be_truthy
          expect(player_1.percent_of(corporation)).to eq(50)
          expect(player_2.percent_of(corporation)).to eq(40)
          expect(player_1.cash).to eq(370)
          expect(player_2.cash).to eq(380)
        end

        it 'should not swap with 2 shares' do
          subject.sell_shares(ShareBundle.new(player_1.shares.last(2)))
          expect(corporation.president?(player_1)).to be_truthy
          expect(player_1.percent_of(corporation)).to eq(40)
          expect(player_2.percent_of(corporation)).to eq(40)
          expect(player_1.shares.size).to eq(3)
          expect(player_2.shares.size).to eq(4)
          expect(player_1.cash).to eq(380)
          expect(player_2.cash).to eq(380)
        end

        it 'should swap with 3 shares' do
          subject.sell_shares(ShareBundle.new(player_1.shares.last(3)))
          expect(corporation.president?(player_2)).to be_truthy
          expect(player_1.percent_of(corporation)).to eq(30)
          expect(player_2.percent_of(corporation)).to eq(40)
          expect(player_1.shares.size).to eq(3)
          expect(player_2.shares.size).to eq(3)
          expect(player_1.cash).to eq(390)
          expect(player_2.cash).to eq(380)
        end

        it 'should swap with 5 shares partial' do
          subject.sell_shares(ShareBundle.new(player_1.shares, 50))
          expect(corporation.president?(player_2)).to be_truthy
          expect(player_1.percent_of(corporation)).to eq(10)
          expect(player_2.percent_of(corporation)).to eq(40)
          expect(player_1.shares.size).to eq(1)
          expect(player_2.shares.size).to eq(3)
          expect(player_1.cash).to eq(410)
          expect(player_2.cash).to eq(380)
        end

        it 'should swap with 6 shares partial' do
          subject.sell_shares(ShareBundle.new(player_1.shares))
          expect(corporation.president?(player_2)).to be_truthy
          expect(player_1.percent_of(corporation)).to eq(0)
          expect(player_2.percent_of(corporation)).to eq(40)
          expect(player_1.shares.size).to eq(0)
          expect(player_2.shares.size).to eq(3)
          expect(player_1.cash).to eq(420)
          expect(player_2.cash).to eq(380)
        end
      end
    end

    describe '1846' do
      context 'receivership' do
        let(:game) { Game::G1846.new(%w[a b c]) }
        let(:round) { game.round }
        let(:step) { game.round.active_step }

        before :each do
          game.stock_market.set_par(corporation, game.stock_market.par_prices[0])
          corporation.ipoed = true
          corporation.owner = subject

          presidents_bundle = ShareBundle.new(corporation.shares_of(corporation).first)
          subject.transfer_shares(presidents_bundle, subject)
        end

        context 'presidents share alone in share pool' do
          it 'only a player with one share can buy the partial presidents bundle' do
            # give player 1 a share
            bundle = ShareBundle.new(corporation.shares_of(corporation).first)
            subject.transfer_shares(bundle, player_1)

            expect(corporation.receivership?).to be true

            expect(player_1.num_shares_of(corporation)).to eq(1)
            expect(player_2.num_shares_of(corporation)).to eq(0)
            expect(player_3.num_shares_of(corporation)).to eq(0)
            expect(subject.num_shares_of(corporation)).to eq(2)
            expect(corporation.num_shares_of(corporation)).to eq(7)

            pool_bundles = subject.bundles_for_corporation(corporation)
            buyable = pool_bundles.select { |b| step.can_buy?(player_1, b) }
            bundle = buyable.first

            # only buyable bundle for player 1 is the partial presidents bundle
            expect(buyable.size).to eq(1)

            # player 2, with no shares, cannot buy any of the bundles in the
            # pool
            expect(pool_bundles.select { |b| step.can_buy?(player_2, b) }).to eq([])

            # buy the share
            action = Engine::Action::BuyShares.new(player_1, shares: bundle.shares, share_price: 150, percent: 10)
            round.process_action(action)

            # new president
            expect(player_1.num_shares_of(corporation)).to eq(2)
            expect(player_2.num_shares_of(corporation)).to eq(0)
            expect(player_3.num_shares_of(corporation)).to eq(0)
            expect(subject.num_shares_of(corporation)).to eq(1)
            expect(corporation.num_shares_of(corporation)).to eq(7)
            expect(corporation.num_market_shares).to eq(1)
            expect(corporation.owner).to be(player_1)
          end
        end
      end
    end
  end
end
