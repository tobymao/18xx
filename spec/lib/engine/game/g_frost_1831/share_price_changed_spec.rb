# frozen_string_literal: true

require 'spec_helper'

module Engine
  module Game
    module GFrost1831
      describe Game do
        let(:game) { Engine::Game::GFrost1831::Game.new(%w[P1 P2 P3], id: 1) }
        let(:p1) { game.players[0] }
        let(:corporation) { game.corporation_by_id('CM') }
        let(:market) { game.stock_market }
        let(:messages) { game.log.map(&:message) }

        def place(row, col)
          corporation.share_price&.corporations&.delete(corporation)
          price = market.share_price([row, col])
          corporation.share_price = price
          price.corporations << corporation
          price
        end

        def give_all_shares(player)
          game.bank.spend(2000, player)
          game.par_corporation(corporation, market.par_prices.find { |p| p.price == 100 })
          corporation.shares.dup.each { |share| game.share_pool.buy_shares(player, share) }
        end

        def dividend_step
          game.instance_variable_set(:@round, game.operating_round(1))
          game.round.steps.find { |step| step.is_a?(GFrost1831::Step::Dividend) }
        end

        it 'claims a first-to-arrive cell reached by a share sale' do
          give_all_shares(p1)
          place(2, 10)
          share = p1.shares_of(corporation).reject(&:president).first

          game.sell_shares_and_change_price(share.to_bundle)

          expect(corporation.share_price.coordinates).to eq([3, 10])
          expect(corporation.share_price.types).not_to include(:pays_bonus_1)
          expect(messages).to include('CM is first to reach £200')
        end

        it 'updates the ownership limit when sold out at the end of the stock round' do
          give_all_shares(p1)
          corporation.floated = true
          place(3, 1)
          game.instance_variable_set(:@round, game.stock_round)

          game.round.send(:finish_round)

          expect(corporation.share_price.coordinates).to eq([2, 1])
          expect(corporation.max_ownership_percent).to eq(100)
        end

        it 'claims a first-to-arrive cell reached by a dividend' do
          place(2, 10)

          dividend_step.change_share_price(corporation, share_direction: :right, share_times: 1)

          expect(corporation.share_price.coordinates).to eq([2, 11])
          expect(messages).to include('CM is first to reach £240')
        end

        it 'lifts the ownership limit when a withheld dividend moves into a no cert limit cell' do
          place(2, 2)
          expect(corporation.max_ownership_percent).to eq(60)

          dividend_step.change_share_price(corporation, share_direction: :left, share_times: 1)

          expect(corporation.share_price.type).to eq(:no_cert_limit)
          expect(corporation.max_ownership_percent).to eq(100)
        end

        it 'moves the share price right only when the total payout reaches the share price' do
          price = place(2, 5).price
          step = dividend_step

          expect(step.share_price_change(corporation, price)).to eq(share_direction: :right, share_times: 1)
          expect(step.share_price_change(corporation, price - 1)).to eq({})
          expect(step.share_price_change(corporation, 0)).to eq(share_direction: :left, share_times: 1)
        end
      end
    end
  end
end
