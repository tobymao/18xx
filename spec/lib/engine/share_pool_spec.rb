# frozen_string_literal: true

require './spec/spec_helper'

require 'engine/game/g_1889'
require 'engine/share_pool'
require 'engine/share_price'
require 'engine/player'

# rubocop:disable Metrics/ModuleLength
module Engine
  describe SharePool do
    let(:game) { Game::G1889.new(%w[a b c]) }
    let(:player_1) { game.player_by_id('a') }
    let(:player_2) { game.player_by_id('b') }
    let(:player_3) { game.player_by_id('c') }
    let(:bank) { game.bank }
    let(:corporation) { game.corporations.first }
    let(:company) { game.companies.first }
    let(:share_price) { SharePrice.from_code('10', 0, 0) }
    let(:subject) { game.share_pool }

    before :each do
      game.stock_market.set_par(corporation, share_price)
      game.send(:next_round!)
    end

    describe '#buy_share' do
      it 'can ipo' do
        subject.buy_share(player_1, corporation.shares.first)
        expect(corporation.ipoed).to be_truthy
        expect(corporation.floated?).to be_falsey
        expect(player_1.cash).to eq(400)
        expect(player_1.percent_of(corporation)).to eq(20)
        expect(corporation.president?(player_1)).to be_truthy
        expect(corporation.cash).to eq(0)
      end

      it 'can float' do
        corporation.shares.take(4).each do |share|
          subject.buy_share(player_1, share)
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
        subject.buy_share(player_1, corporation.shares[0])
        subject.buy_share(player_2, corporation.shares[1])
        subject.buy_share(player_2, corporation.shares[2])
        expect(corporation.president?(player_1)).to be_truthy

        subject.buy_share(player_2, corporation.shares[3])
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
          subject.buy_share(player_1, corporation.shares[1], exchange: company)
          expect(corporation.ipoed).to be_falsey
          expect(corporation.president?(player_1)).to be_falsey
          expect(player_1.cash).to eq(420)
          expect(player_1.percent_of(corporation)).to eq(10)
        end

        it 'floats' do
          corporation.shares[0..2].dup.each do |share|
            subject.buy_share(player_1, share)
          end

          expect(corporation.floated?).to be_falsey
          expect(corporation.cash).to eq(0)

          subject.buy_share(player_1, corporation.shares[0], exchange: company)
          expect(corporation.floated?).to be_truthy
          expect(corporation.cash).to eq(100)
        end
      end
    end

    describe '#sell_share' do
      it 'respects order for president swap' do
        corporation.shares[0..1].dup.each do |share|
          subject.buy_share(player_2, share)
        end

        corporation.shares[0..2].dup.each do |share|
          subject.buy_share(player_1, share)
        end

        corporation.shares[0..2].dup.each do |share|
          subject.buy_share(player_3, share)
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
            subject.buy_share(player_1, share)
          end

          corporation.shares.dup.each do |share|
            subject.buy_share(player_2, share)
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
  end
end
# rubocop:enable Metrics/ModuleLength
