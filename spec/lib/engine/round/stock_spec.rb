# frozen_string_literal: true

require './spec/spec_helper'

require 'engine/game/g_1889'
require 'engine/game/g_1882'
require 'engine/phase'
require 'engine/round/operating'

module Engine
  describe Round::Stock do
    let(:players) { %w[a b c d e f] }
    let(:game) { Game::G1889.new(players) }
    let(:market) { game.stock_market }
    let(:corp_0) { game.corporations[0] }
    let(:corp_1) { game.corporations[1] }
    let(:corp_2) { game.corporations[2] }
    let(:corp_3) { game.corporations[3] }
    let(:player_0) { game.players[0] }
    let(:player_1) { game.players[1] }
    subject { move_to_sr! }

    def move_to_sr!
      # Move the game into an SR

      game.send(:next_round!) until game.round.is_a?(Round::Stock)

      game.round
    end

    describe '#can_buy?' do
      it 'can buy yellow at limit' do
        player_0.cash = 10_000
        market.set_par(corp_0, market.market[2][4])
        market.set_par(corp_1, market.market[2][4])
        market.set_par(corp_2, market.market[2][4])
        market.set_par(corp_3, market.market[6][0])
        5.times { game.share_pool.buy_shares(player_0, corp_0.shares[0]) }
        5.times { game.share_pool.buy_shares(player_0, corp_1.shares[0]) }
        1.times { game.share_pool.buy_shares(player_0, corp_2.shares[0]) } # at 6-player cert limit
        1.times { game.share_pool.buy_shares(player_1, corp_3.shares[0]) } # at 6-player cert limit

        expect(subject.active_step.can_buy?(player_0, corp_2.shares[0])).to eq(false)
        expect(subject.active_step.can_buy?(player_0, corp_3.shares[0])).to eq(true)
        expect(subject.active_step.can_buy_any?(player_0)).to eq(true)
      end

      it 'works with no par' do
        expect(subject.active_step.can_buy?(player_0, corp_0.shares[0])).to be_truthy
      end

      it "can't buy when at cert limit when doing so would gain you the presidency" do
        player_0.cash = 10_000
        player_1.cash = 10_000
        market.set_par(corp_0, market.market[2][4])
        market.set_par(corp_1, market.market[2][4])
        market.set_par(corp_2, market.market[2][4])
        market.set_par(corp_3, market.market[6][0])

        # Make player 1 president
        3.times { game.share_pool.buy_shares(player_1, corp_0.shares[0]) }

        # Get player 0 to the same quantity and to cert limit
        4.times { game.share_pool.buy_shares(player_0, corp_0.shares[0]) }
        4.times { game.share_pool.buy_shares(player_0, corp_1.shares[0]) }
        3.times { game.share_pool.buy_shares(player_0, corp_2.shares[0]) } # at 6-player cert limit

        # Double check it's player 0 to operate
        expect(subject.current_entity).to eq(player_0)
        # Check player 1 is actually the president
        expect(corp_0.president?(player_1)).to eq(true)

        expect(subject.active_step.can_buy?(player_0, corp_0.shares[0])).to eq(false)
      end

      it 'can\'t buy over 60%' do
        player_0.cash = 10_000
        market.set_par(corp_0, market.market[7][0])
        6.times { game.share_pool.buy_shares(player_0, corp_0.shares[0]) }
        expect(subject.active_step.can_buy?(player_0, corp_0.shares[0])).to eq(false)
      end

      it 'can buy orange over 60%' do
        player_0.cash = 10_000
        market.set_par(corp_0, market.market[8][0])
        6.times { game.share_pool.buy_shares(player_0, corp_0.shares[0]) }
        expect(subject.active_step.can_buy?(player_0, corp_0.shares[0])).to eq(true)
      end

      it 'must sell when over 60%' do
        player_0.cash = 10_000
        market.set_par(corp_0, market.market[7][0])
        7.times { game.share_pool.buy_shares(player_0, corp_0.shares[0]) }
        expect(subject.active_step.must_sell?(player_0)).to eq(true)
      end

      it 'needn\'t sell orange when over 60%' do
        player_0.cash = 10_000
        market.set_par(corp_0, market.market[8][0])
        7.times { game.share_pool.buy_shares(player_0, corp_0.shares[0]) }
        expect(subject.active_step.must_sell?(player_0)).to eq(false)
      end

      context '#1882' do
        let(:game) { Game::G1882.new(players) }
        let(:corp_0) { game.corporation_by_id('QLL') }
        let(:corp_0) { game.corporation_by_id('CPR') }

        it 'can buy multiple stocks from ipo in brown' do
          market.set_par(corp_0, market.market.last[0]) # 10
          game.share_pool.buy_shares(player_0, corp_0.shares[0])
          ipo_share = corp_0.shares[0]
          expect(subject.active_step.can_buy?(player_0, ipo_share)).to be_truthy
          entity = subject.current_entity
          action = Engine::Action::BuyShares.new(subject.current_entity, shares: ipo_share)
          subject.process_action(action)
          ipo_share = corp_0.shares[1]
          expect(subject.current_entity).to eq(entity)
          expect(subject.active_step.can_buy?(player_0, ipo_share)).to be_truthy
          action = Engine::Action::BuyShares.new(entity, shares: ipo_share)
          subject.process_action(action)
        end

        it 'cannot buy stocks from second company after buying one brown' do
          market.set_par(corp_0, market.market.last[0]) # 10
          game.share_pool.buy_shares(player_0, corp_0.shares[0])
          ipo_share = corp_0.shares[0]
          expect(subject.active_step.can_buy?(player_0, ipo_share)).to be_truthy
          entity = subject.current_entity
          action = Engine::Action::BuyShares.new(subject.current_entity, shares: ipo_share)
          subject.process_action(action)
          ipo_share = corp_1.shares[1]
          expect(subject.current_entity).to eq(entity)
          expect(subject.active_step.can_buy?(player_0, ipo_share)).to be_falsey
        end
      end
    end
  end
end
