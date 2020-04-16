# frozen_string_literal: true

require './spec/spec_helper'

require 'engine/bank'
require 'engine/corporation'
require 'engine/game/g_1889'
require 'engine/share'
require 'engine/share_pool'
require 'engine/share_price'
require 'engine/player'

module Engine
  describe SharePool do
    let(:game) { Game::G1889.new([]) }
    let(:bank) { game.bank }
    let(:player) { Player.new('a') }
    let(:corporation) { Corporation.new(sym: 'a', name: 'a', tokens: [0]) }
    let(:share_price) { SharePrice.from_code('10', 0, 0) }
    let(:subject) { SharePool.new(game) }
    let(:share) { Share.new(corporation, owner: subject, president: true, percent: 20) }

    before :each do
      bank.spend(100, player)
      corporation.share_price = share_price
      corporation.par_price = share_price
    end

    describe '#buy_share' do
      it 'sends money and share to right place' do
        expect { subject.buy_share(player, share) }.to change { bank.cash }.by(20)
      end
    end

    describe '#sell_share' do
      before :each do
        subject.buy_share(player, share)
      end

      it 'sends money and share to right place' do
        expect { subject.sell_shares([share]) }.to change { bank.cash }.by(-20)
      end
    end
  end
end
