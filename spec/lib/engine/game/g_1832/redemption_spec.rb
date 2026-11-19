# frozen_string_literal: true

require 'spec_helper'
require_relative 'system_context'

module Engine
  describe Game::G1832::Game do
    let(:game) { Game::G1832::Game.new(%w[a b c]) }

    describe 'system share redemption' do
      include_context 'with a system formed from ACL and SALR'

      let(:step) { game.round.active_step }

      before do
        system.instance_variable_set(:@operating_history, { [1, 1] => :ran })
        game.bank.spend(1000, system)
      end

      # Leave the system holding `percent` of itself, with the rest of the shares in the market.
      def hold_in_treasury(percent)
        while system.shares_of(system).sum(&:percent) > percent
          system.shares_of(system).reject(&:president).min_by(&:percent).transfer(game.share_pool)
        end
        act_as(player_a)
      end

      it 'can redeem up to 40% of itself, counted in percent rather than in shares' do
        [35, 30, 20].each do |percent|
          hold_in_treasury(percent)

          expect(step.actions(system)).to include('buy_shares'), "expected a redemption at #{percent}%"
        end
      end

      it 'cannot redeem once it holds 40% of itself' do
        hold_in_treasury(40)

        expect(step.actions(system)).to be_empty
      end

      it 'cannot redeem a certificate that would take it past 40%' do
        hold_in_treasury(35)
        game.share_pool.shares_of(system).dup.each { |share| share.transfer(player_c) }
        system.vice_president_certs.first.transfer(game.share_pool)
        act_as(player_a)

        bundle = step.redeemable_shares(system).first

        expect(bundle.percent).to eq(10)
        expect(step.actions(system)).to include('buy_shares')
        expect(step.can_buy?(system, bundle)).to be(false)
      end

      it 'redeems a 5% share from the market while under 40%' do
        hold_in_treasury(35)
        share = game.share_pool.shares_of(system).find { |s| s.percent == 5 }
        bundle = ShareBundle.new([share])

        expect(step.can_buy?(system, bundle)).to be(true)

        game.process_action(
          Action::BuyShares.new(system, shares: [share], share_price: bundle.share_price, percent: 5)
        )

        expect(system.shares_of(system).sum(&:percent)).to eq(40)
      end

      def redeem(corporation)
        bundle = step.redeemable_shares(corporation).first
        game.process_action(
          Action::BuyShares.new(corporation, shares: bundle.shares, share_price: bundle.share_price,
                                             percent: bundle.percent)
        )
        raise game.exception if game.exception
      end

      # The other players take their turns, then it is the president's again.
      def next_turn
        game.round.current_actions.clear
        act_as(player_a)
      end

      it 'lets a system redeem two shares in a stock round, one per turn, and not a third' do
        hold_in_treasury(20)

        redeem(system)
        expect(game.round.redemptions[system]).to eq(1)
        expect(step.actions(system)).to be_empty # one per turn

        next_turn
        expect(step.actions(system)).to include('buy_shares')
        redeem(system)
        expect(game.round.redemptions[system]).to eq(2)

        next_turn
        expect(system.shares_of(system).sum(&:percent)).to eq(30)
        expect(step.actions(system)).to be_empty
      end

      it 'keeps the turn open for a player who can act only through the system' do
        hold_in_treasury(20)
        player_a.spend(player_a.cash, game.bank) if player_a.cash.positive?
        player_a.shares.dup.each { |share| share.transfer(player_c) unless share.president }
        act_as(player_a)

        expect(step.actions(system)).to include('buy_shares')
        expect(step.actions(player_a)).to eq(['pass'])
      end

      it 'refuses a third redemption by a system even if one is submitted' do
        hold_in_treasury(20)
        game.round.redemptions[system] = 2
        share = game.share_pool.shares_of(system).find { |s| s.percent == 5 }

        expect(step.can_buy?(system, ShareBundle.new([share]))).to be(false)
      end

      it 'lets an ordinary corporation redeem only one share in a stock round' do
        corp = game.corporation_by_id('GRR')
        game.par_corporation(corp, game.stock_market.par_prices.find { |p| p.price == 100 })
        corp.ipoed = true
        give(player_a, [corp.presidents_share, *corp.ipo_shares.reject(&:president).first(2)])
        give(player_c, corp.ipo_shares.reject(&:president).first(3))
        corp.instance_variable_set(:@operating_history, { [1, 1] => :ran })
        act_as(player_a)

        expect(step.actions(corp)).to include('buy_shares')

        game.round.redemptions[corp] = 1
        next_turn

        expect(step.actions(corp)).to be_empty
      end

      it 'still limits an ordinary corporation to four 10% shares' do
        corp = game.corporation_by_id('GRR')
        game.par_corporation(corp, game.stock_market.par_prices.find { |p| p.price == 100 })
        corp.ipoed = true
        give(player_a, [corp.presidents_share, *corp.ipo_shares.reject(&:president).first(2)])
        give(player_c, corp.ipo_shares.reject(&:president).first(2))
        corp.instance_variable_set(:@operating_history, { [1, 1] => :ran })
        act_as(player_a)

        expect(corp.owner).to eq(player_a)
        expect(corp.shares_of(corp).sum(&:percent)).to eq(40)
        expect(step.actions(corp)).to be_empty

        give(player_b, corp.ipo_shares.reject(&:president).first(1))
        act_as(player_a)

        expect(corp.shares_of(corp).sum(&:percent)).to eq(30)
        expect(step.actions(corp)).to include('buy_shares')
      end
    end
  end
end
