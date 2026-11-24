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

      it 'redeems a vice-president certificate from the market as its whole 10% for the round' do
        hold_in_treasury(20)
        game.share_pool.shares_of(system).dup.each { |share| share.transfer(player_c) }
        vp_cert = system.vice_president_certs.first
        vp_cert.transfer(game.share_pool)
        act_as(player_a)

        expect(step.redeemable_shares(system).map(&:percent)).to eq([10])

        redeem(system)
        game.share_pool.shares_of(system)
        next_turn
        system.shares_of(system).find { |share| share.percent == 5 }.transfer(game.share_pool)

        expect(game.round.redeemed_percent[system]).to eq(10)
        expect(step.actions(system)).to be_empty
      end

      it 'offers a market vice-president certificate only when no 5% share is in the market' do
        hold_in_treasury(20)
        game.share_pool.shares_of(system).dup.each { |share| share.transfer(player_c) }
        system.vice_president_certs.first.transfer(game.share_pool)
        five_percent = system.shares_of(system).find { |share| share.percent == 5 }
        five_percent.transfer(game.share_pool)
        act_as(player_a)

        expect(step.redeemable_shares(system).map(&:percent)).to eq([5])

        five_percent.transfer(player_c)

        expect(step.redeemable_shares(system).map(&:percent)).to eq([10])
      end

      it 'cannot redeem a vice-president certificate after a 5% share' do
        hold_in_treasury(20)
        game.share_pool.shares_of(system).dup.each { |share| share.transfer(player_c) }
        vp_cert = system.vice_president_certs.first
        vp_cert.transfer(game.share_pool)
        system.shares_of(system).find { |share| share.percent == 5 }.transfer(game.share_pool)
        act_as(player_a)

        redeem_percent(system, 5)
        next_turn

        expect(step.redeemable_shares(system)).to be_empty
        expect(step.can_buy?(system, ShareBundle.new([vp_cert]))).to be(false)
      end

      it 'does not offer a market vice-president certificate that would take it past 40%' do
        hold_in_treasury(35)
        game.share_pool.shares_of(system).dup.each { |share| share.transfer(player_c) }
        vp_cert = system.vice_president_certs.first
        vp_cert.transfer(game.share_pool)
        act_as(player_a)

        expect(step.actions(system)).to be_empty
        expect(step.redeemable_shares(system)).to be_empty
        expect(step.can_buy?(system, ShareBundle.new([vp_cert]))).to be(false)
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

      def redeem_percent(corporation, percent)
        bundle = step.redeemable_shares(corporation).find { |b| b.percent == percent }
        game.process_action(
          Action::BuyShares.new(corporation, shares: bundle.shares, share_price: bundle.share_price,
                                             percent: bundle.percent)
        )
        raise game.exception if game.exception
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
        expect(game.round.redeemed_percent[system]).to eq(5)
        expect(step.actions(system)).to be_empty # one per turn

        next_turn
        expect(step.actions(system)).to include('buy_shares')
        redeem(system)
        expect(game.round.redeemed_percent[system]).to eq(10)

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
        game.round.redeemed_percent[system] = 10
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

        game.round.redeemed_percent[corp] = 10
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

    describe 'redeeming from players' do
      include_context 'with a system formed from ACL and SALR'

      let(:step) { game.round.active_step }
      let(:corp) { game.corporation_by_id('GRR') }

      def redeem(bundle)
        game.process_action(
          Action::BuyShares.new(corp, shares: bundle.shares, share_price: bundle.share_price, percent: bundle.percent)
        )
        raise game.exception if game.exception
      end

      def redeemable_owners
        step.redeemable_shares(corp).map(&:owner)
      end

      before do
        game.par_corporation(corp, game.stock_market.par_prices.find { |p| p.price == 100 })
        corp.ipoed = true
        corp.instance_variable_set(:@operating_history, { [1, 1] => :ran })
        game.bank.spend(1000, corp)
      end

      context 'when the market holds none of its shares' do
        before do
          give(player_a, [corp.presidents_share, *corp.ipo_shares.reject(&:president).first(2)])
          give(player_c, corp.ipo_shares.reject(&:president).first(3))
          act_as(player_a)
        end

        it 'redeems a share from a player who is not its president' do
          bundle = step.redeemable_shares(corp).find { |b| b.owner == player_c }
          cash = player_c.cash

          redeem(bundle)

          expect(player_c.percent_of(corp)).to eq(20)
          expect(player_c.cash).to eq(cash + bundle.price)
          expect(corp.shares_of(corp).sum(&:percent)).to eq(40)
        end

        it 'redeems a share from its president while the president keeps the presidency' do
          expect(redeemable_owners).to include(player_a)

          redeem(step.redeemable_shares(corp).find { |b| b.owner == player_a })

          expect(corp.owner).to eq(player_a)
          expect(player_a.percent_of(corp)).to eq(30)
        end

        it 'leaves the shares left in the IPO for any player to buy, including the one who sold' do
          redeem(step.redeemable_shares(corp).find { |b| b.owner == player_c })
          act_as(player_c)

          expect(step.can_buy?(player_c, corp.ipo_shares.reject(&:president).first.to_bundle)).to be(true)
        end
      end

      it 'does not redeem from its president if another player would take over the presidency' do
        give(player_a, [corp.presidents_share, corp.ipo_shares.reject(&:president).first])
        give(player_c, corp.ipo_shares.reject(&:president).first(3))
        give(player_b, corp.ipo_shares.reject(&:president).first(1))
        act_as(player_a)

        expect(redeemable_owners).to contain_exactly(player_b, player_c)
      end

      it 'redeems a system share from its president without a certificate that would cost the presidency' do
        system.instance_variable_set(:@operating_history, { [1, 1] => :ran })
        game.bank.spend(1000, system)
        system.vice_president_certs.first.transfer(player_a)
        give(player_a, system.shares_of(system).first(1))
        give(player_c, system.shares_of(system).first(5))
        act_as(player_a)

        bundle = step.redeemable_shares(system).find { |b| b.owner == player_a }

        expect(bundle.percent).to eq(5)
        expect(player_a.percent_of(system)).to eq(35)
        expect(player_c.percent_of(system)).to eq(30)
      end

      it 'does not redeem a vice-president certificate from a player' do
        system.instance_variable_set(:@operating_history, { [1, 1] => :ran })
        game.bank.spend(1000, system)
        give(player_c, system.shares_of(system).first(6))
        act_as(player_a)

        expect(player_b.shares_of(system).map(&:percent)).to eq([10])
        owners = step.redeemable_shares(system).map(&:owner)

        expect(owners).to include(player_c)
        expect(owners).not_to include(player_b)
      end

      it 'redeems a vice-president certificate from a player when no 5% certificate is available' do
        system.instance_variable_set(:@operating_history, { [1, 1] => :ran })
        game.bank.spend(1000, system)
        [player_a, player_c].each do |player|
          player.shares_of(system).reject(&:president).each { |share| share.transfer(system) }
        end
        system.shares_of(system).first(8).each { |share| share.transfer(corp) }
        act_as(player_a)

        bundles = step.redeemable_shares(system)

        expect(bundles.map(&:owner)).to eq([player_b])
        expect(bundles.map(&:percent)).to eq([10])
      end

      it 'does not offer a vice-president certificate from a player that would take it past 40%' do
        system.instance_variable_set(:@operating_history, { [1, 1] => :ran })
        game.bank.spend(1000, system)
        [player_a, player_c].each do |player|
          player.shares_of(system).reject(&:president).each { |share| share.transfer(system) }
        end
        system.shares_of(system).first(7).each { |share| share.transfer(corp) }
        act_as(player_a)

        expect(system.shares_of(system).sum(&:percent)).to eq(35)
        expect(step.actions(system)).to be_empty
        expect(step.redeemable_shares(system)).to be_empty
      end

      it 'offers only the market shares while the market holds any' do
        give(player_a, [corp.presidents_share, *corp.ipo_shares.reject(&:president).first(2)])
        give(player_c, corp.ipo_shares.reject(&:president).first(3))
        player_c.shares_of(corp).first.transfer(game.share_pool)
        act_as(player_a)

        expect(redeemable_owners).to eq([game.share_pool])
      end
    end
  end
end
