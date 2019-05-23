# frozen_string_literal: true

require './spec/spec_helper'

require 'engine/corporation/base'
require 'engine/stock_market'

module Engine
  describe StockMarket do
    let(:subject) { StockMarket.new(StockMarket::MARKET) }
    let(:corporation) { Corporation::Base.new('a', name: 'a', tokens: 1) }

    describe '#move_right' do
      it 'moves right' do
        current_price = subject.market[0][0]
        subject.set_par(corporation, current_price)
        subject.move_right(corporation)
        expect(corporation.share_price).to be(subject.market[0][1])
        expect(current_price.corporations).to eq([])
      end

      it 'moves up at wall' do
        current_price = subject.market[1].last
        subject.set_par(corporation, current_price)
        subject.move_right(corporation)
        expect(corporation.share_price).to be(subject.market[0].last)
        expect(current_price.corporations).to eq([])
      end
    end

    describe '#move_up' do
      it 'moves up' do
        current_price = subject.market[1][0]
        subject.set_par(corporation, current_price)
        subject.move_up(corporation)
        expect(corporation.share_price).to be(subject.market[0][0])
        expect(current_price.corporations).to eq([])
      end

      it 'stays put at ceiling' do
        current_price = subject.market[0][0]
        subject.set_par(corporation, current_price)
        subject.move_up(corporation)
        expect(corporation.share_price).to be(current_price)
        expect(current_price.corporations).to eq([corporation])
      end
    end

    describe '#move_left' do
      it 'moves left' do
        current_price = subject.market[1][1]
        subject.set_par(corporation, current_price)
        subject.move_left(corporation)
        expect(corporation.share_price).to be(subject.market[1][0])
        expect(current_price.corporations).to eq([])
      end

      it 'stays put at wall' do
        current_price = subject.market[0][0]
        subject.set_par(corporation, current_price)
        subject.move_left(corporation)
        expect(corporation.share_price).to be(current_price)
        expect(current_price.corporations).to eq([corporation])
      end
    end

    describe '#move_down' do
      it 'moves down' do
        current_price = subject.market[0][0]
        subject.set_par(corporation, current_price)
        subject.move_down(corporation)
        expect(corporation.share_price).to be(subject.market[1][0])
        expect(current_price.corporations).to eq([])
      end

      it 'stays put at cliff' do
        current_price = subject.market[7][0]
        subject.set_par(corporation, current_price)
        subject.move_down(corporation)
        expect(corporation.share_price).to be(current_price)
        expect(current_price.corporations).to eq([corporation])
      end
    end
  end
end
