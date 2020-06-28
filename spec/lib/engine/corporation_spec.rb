# frozen_string_literal: true

require './spec/spec_helper'

require 'engine'
require 'engine/corporation'
require 'engine/share_price'

module Engine
  describe Corporation do
    let(:corporation_1) { Engine::Corporation.new(sym: 'a', name: 'a', tokens: []) }
    let(:corporation_2) { Engine::Corporation.new(sym: 'b', name: 'b', tokens: []) }
    let(:corporation_3) { Engine::Corporation.new(sym: 'c', name: 'c', tokens: []) }
    let(:corporation_4) { Engine::Corporation.new(sym: 'd', name: 'd', tokens: []) }
    let(:corporations) { [corporation_1, corporation_2, corporation_3, corporation_4] }

    let(:market) { Engine::StockMarket.new(Engine::Game::G1889::MARKET, []) }
    let(:share_price_100) { market.market[1][4] }
    let(:share_price_100_r) { market.market[2][5] }
    let(:share_price_110) { market.market[0][4] }

    describe '#<=>' do
      it 'should sort' do
        expect(share_price_100.price).to eq(100)
        expect(share_price_100_r.price).to eq(100)
        expect(share_price_110.price).to eq(110)
        market.set_par(corporation_1, share_price_100)
        market.set_par(corporation_2, share_price_100)
        market.set_par(corporation_3, share_price_100_r)
        market.set_par(corporation_4, share_price_110)
        expect(corporations.sort).to eq([corporation_4, corporation_3, corporation_1, corporation_2])
      end

      it 'should sort inverse' do
        expect(share_price_100.price).to eq(100)
        expect(share_price_100_r.price).to eq(100)
        expect(share_price_110.price).to eq(110)
        market.set_par(corporation_2, share_price_100)
        market.set_par(corporation_1, share_price_100)
        market.set_par(corporation_3, share_price_100_r)
        market.set_par(corporation_4, share_price_110)
        expect(corporations.sort).to eq([corporation_4, corporation_3, corporation_2, corporation_1])
      end
    end
  end
end
