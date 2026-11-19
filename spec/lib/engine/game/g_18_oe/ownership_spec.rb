# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE ordinary stock purchase threshold (PB §5.4, §10.2)' do
  include G18OESpecHelpers

  shared_examples 'a stock purchase threshold' do |klass, player_count, threshold, optional_rules|
    let(:game) { new_game(Array.new(player_count) { |i| "p#{i}" }, klass: klass, optional_rules: optional_rules) }
    let(:president) { game.players.first }
    let(:major) { start_major!(game, 'LNWR', president) }
    let(:round) { stock_round!(game) }
    let(:step) { round.active_step }

    before do
      allow(game).to receive(:major_phase?).and_return(true)
      major
    end

    it "allows a treasury purchase up to #{threshold}% and blocks further treasury purchases" do
      take_treasury_shares!(game, president, major, (threshold - 30) / 10)
      share = major.ipo_shares.first
      expect(step.can_buy?(president, share.to_bundle)).to be(true)

      act!(round, Engine::Action::BuyShares.new(president, shares: [share]))

      expect(president.percent_of(major)).to eq(threshold)
      fresh = stock_round!(game).active_step
      expect(fresh.can_buy?(president, major.ipo_shares.first.to_bundle)).to be(false)
    end

    it "charges normal market price through #{threshold}% and double price beyond it" do
      take_treasury_shares!(game, president, major, (threshold - 30) / 10)
      game.share_pool.transfer_shares(Engine::ShareBundle.new(major.ipo_shares.first(2)), game.share_pool)
      share = game.share_pool.shares_of(major).first
      cash = president.cash
      price = major.share_price.price
      expect(step.can_buy?(president, share.to_bundle)).to be(true)
      expect(step.modify_purchase_price(share.to_bundle)).to eq(price)

      act!(round, Engine::Action::BuyShares.new(president, shares: [share]))

      expect(president.cash).to eq(cash - price)
      expect(president.percent_of(major)).to eq(threshold)
      fresh_round = stock_round!(game)
      fresh = fresh_round.active_step
      next_share = game.share_pool.shares_of(major).first
      expect(fresh.can_buy?(president, next_share.to_bundle)).to be(true)
      expect(fresh.modify_purchase_price(next_share.to_bundle)).to eq(price * 2)

      act!(fresh_round, Engine::Action::BuyShares.new(
                          president, shares: [next_share], share_price: fresh.modify_purchase_price(next_share.to_bundle)
                        ))

      expect(president.cash).to eq(cash - (price * 3))
      expect(president.percent_of(major)).to eq(threshold + 10)
      expect(game.can_hold_above_corp_limit?(president)).to be(true)
    end
  end

  context 'with two players in the full game' do
    it_behaves_like 'a stock purchase threshold', Engine::Game::G18OE::Game, 2, 70, []
  end

  (3..7).each do |player_count|
    context "with #{player_count} players in the full game" do
      it_behaves_like 'a stock purchase threshold', Engine::Game::G18OE::Game, player_count, 60, []
    end
  end

  context 'with two players in UK–France' do
    it_behaves_like 'a stock purchase threshold', Engine::Game::G18OEUKFR::Game, 2, 70, []
  end

  context 'with three players in UK–France' do
    it_behaves_like 'a stock purchase threshold', Engine::Game::G18OEUKFR::Game, 3, 60, []
  end

  context 'with two players and Long Endgame' do
    it_behaves_like 'a stock purchase threshold', Engine::Game::G18OE::Game, 2, 70, [:long_endgame]
  end

  context 'with three players and Medium Start' do
    it_behaves_like 'a stock purchase threshold', Engine::Game::G18OE::Game, 3, 60, [:medium_start]
  end
end
