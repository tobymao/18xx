# frozen_string_literal: true

require 'spec_helper'

module Engine
  describe Game::G1832::Game do
    let(:game) { Game::G1832::Game.new(%w[a b c]) }
    let(:player_a) { game.players[0] }
    let(:player_b) { game.players[1] }
    let(:player_c) { game.players[2] }
    let(:acl) { game.corporation_by_id('ACL') }
    let(:salr) { game.corporation_by_id('SALR') }
    let(:gmo) { game.corporation_by_id('GMO') }
    let(:sou) { game.corporation_by_id('SOU') }
    let(:round) { game.send(:new_merger_round) }
    let(:step_class) { Game::G1832::Step::MergerPriceProtection }

    def give(player, shares)
      game.share_pool.buy_shares(player, ShareBundle.new(shares), exchange: :free)
    end

    # ACL takes over SALR, which costs $1000. A is ACL's president and can only raise the last $200 by selling
    # GMO shares, for which B, GMO's president, may then price protect.
    before do
      game.send(:next_round!)
      par = game.stock_market.par_prices.find { |p| p.price == 100 }
      hex = game.hex_by_id('D16')
      hex.lay(game.tiles.find { |t| t.color == :green && t.cities.any? { |c| c.slots == 2 } })
      [acl, salr, gmo].each do |corp|
        game.par_corporation(corp, par)
        corp.ipoed = true
        corp.floated = true
        corp.instance_variable_set(:@operating_history, { [1, 1] => :ran })
      end
      [acl, salr].each { |corp| hex.tile.cities.first.place_token(corp, corp.tokens[0], free: true, check_tokenable: false) }
      give(player_b, [gmo.presidents_share])
      give(player_b, gmo.ipo_shares.reject(&:president).first(1))
      give(player_a, gmo.ipo_shares.reject(&:president).first(2))
      give(player_a, [acl.presidents_share])
      give(player_b, [salr.presidents_share])
      player_a.spend(player_a.cash, game.bank)
      game.bank.spend(800, acl)
      allow(game).to receive(:operating_order).and_return([acl, salr])
      game.instance_variable_set(:@round, round)
      round.process_action(Action::Merge.new(acl, corporation: salr))
      round.process_action(Action::Choose.new(acl, choice: 'takeover'))
    end

    def sell_percent(player, corporation, percent)
      bundle = game.bundles_for_corporation(player, corporation).find { |b| b.percent == percent }
      round.process_action(
        Action::SellShares.new(player, shares: bundle.shares, share_price: bundle.price_per_share, percent: bundle.percent)
      )
    end

    def sell_gmo(percent)
      sell_percent(player_a, gmo, percent)
    end

    def par_sou(president)
      game.par_corporation(sou, game.stock_market.par_prices.find { |p| p.price == 100 })
      sou.ipoed = true
      give(president, [sou.presidents_share])
      give(player_a, sou.ipo_shares.reject(&:president).first(1))
    end

    describe 'selling shares to fund a takeover' do
      it 'completes the takeover' do
        sell_gmo(20)

        expect(salr).to be_closed
        expect(player_a.cash).to eq(0)
      end

      it 'waits until the takeover is funded before offering the sold shares for price protection' do
        sell_gmo(10)

        expect(salr).not_to be_closed
        expect(round.active_step).to be_a(Game::G1832::Step::SellSharesForTakeover)
        expect(game.sell_queue.size).to eq(1)

        sell_gmo(10)

        expect(salr).to be_closed
        expect(round.active_step).to be_a(step_class)
      end

      it 'offers the sold shares to the corporation\'s president for price protection before the round goes on' do
        sell_gmo(20)

        expect(round.active_step).to be_a(step_class)
        expect(round.current_entity).to eq(player_b)
        expect(round.actions_for(player_b)).to include('buy_shares', 'pass')
      end

      it 'settles price protection before the buyer may merge or take over again' do
        merge_step = round.steps.find { |s| s.is_a?(Game::G1832::Step::Merge) }
        allow(merge_step).to receive(:mergeable_corporations).and_return([gmo])
        sell_gmo(20)

        expect(round.active_step).to be_a(step_class)

        round.process_action(Action::Pass.new(player_b))

        expect(round.active_step).to be(merge_step)
        expect(round.current_entity).to eq(acl)
      end

      it 'offers the sold shares in the order they were sold' do
        par_sou(player_c)
        sell_percent(player_a, sou, 10)
        sell_gmo(10)

        expect(round.current_entity).to eq(player_c)

        round.process_action(Action::Pass.new(player_c))

        expect(round.current_entity).to eq(player_b)
      end

      it 'does not let a president price protect their own sale of another corporation' do
        par_sou(player_a)
        sell_percent(player_a, sou, 10)
        sell_gmo(20)

        expect(player_a.cash).to be >= 100
        expect(sou.share_price.price).to be < 100
        expect(game.sell_queue.map { |bundle, _| bundle.corporation }).to eq([gmo])
        expect(round.current_entity).to eq(player_b)
      end

      it 'holds the price drops until the takeover is funded' do
        par_sou(player_a)
        sell_percent(player_a, sou, 10)

        expect(round.active_step).to be_a(Game::G1832::Step::SellSharesForTakeover)
        expect(sou.share_price.price).to eq(100)
        expect(game.sell_queue.size).to eq(1)
      end

      it 'drops the share price when the president does not price protect' do
        sell_gmo(20)
        round.process_action(Action::Pass.new(player_b))

        expect(gmo.share_price.price).to eq(82)
        expect(round.active_step).not_to be_a(step_class)
        expect(game.sell_queue).to be_empty
      end

      it 'leaves the price alone when the president price protects' do
        sell_gmo(20)
        bundle = game.sell_queue.first.first
        round.process_action(Action::BuyShares.new(player_b, shares: bundle.shares, share_price: bundle.price_per_share,
                                                             percent: bundle.percent))

        expect(gmo.share_price.price).to eq(100)
        expect(player_b.shares_of(gmo).sum(&:percent)).to eq(50)
        expect(game.sell_queue).to be_empty
      end
    end

    describe 'the order of the corporations after price protection' do
      it 'goes on with the corporations still to act in the order of their share prices' do
        remaining = round.entities[(round.entity_index + 1)..]
        expect(remaining).to include(salr, gmo)
        3.times { game.stock_market.move_down(salr) }
        game.stock_market.move_up(gmo)

        round.recalculate_order

        expect(round.entities[(round.entity_index + 1)..]).to eq(round.select_entities.select { |e| remaining.include?(e) })
        expect(round.entities.index(gmo)).to be < round.entities.index(salr)
      end
    end
  end
end
