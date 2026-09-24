# frozen_string_literal: true

require 'spec_helper'

module Engine
  module Game
    module G18Cuba
      describe Game do
        let(:players) { %w[a b c] }
        let(:game) { Engine::Game::G18Cuba::Game.new(players) }
        let(:stock_market) { game.stock_market }
        let(:corporation) { game.corporations.find { |c| c.type == :major } }

        # One ladder in price order; zigzag splits it, odd indices to the upper row (rulebook p. 4).
        it 'matches the printed share price board' do
          expect(stock_market.market.first.map(&:price)).to eq(
            [50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 110, 115, 120, 126, 132, 138,
             144, 151, 158, 165, 172, 180, 188, 196, 204, 213, 222, 231, 240, 250, 260, 275, 290, 300]
          )
        end

        # Rule VIII.1: a marker on $55 moving one space left drops to $50 instead of holding.
        it 'follows the ledge arrow at the bottom of the ladder' do
          stock_market.set_par(corporation, stock_market.market.first[1])
          stock_market.move_left(corporation)
          expect(corporation.share_price.price).to eq(50)
        end

        # Rule VIII.1: the opposite arrow, reached through ZigZagMovement#right rather than #left.
        it 'follows the ledge arrow at the top of the ladder' do
          stock_market.set_par(corporation, stock_market.market.first[-2])
          stock_market.move_right(corporation)
          expect(corporation.share_price.price).to eq(300)
        end
      end
    end
  end
end
