# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

[Engine::Game::G18OE::Game, Engine::Game::G18OEUKFR::Game].each do |klass|
  describe "#{klass.title} corporate share transactions (§11.7)" do
    include G18OESpecHelpers

    let(:game) { new_game(%w[a b], klass: klass) }
    let!(:major) { start_major!(game, 'LNWR', game.players.first) }
    let(:round) { enter_round!(game, game.operating_round(1)) }
    let(:step) { round_step(round, Engine::Game::G18OE::Step::IssueShares) }

    before do
      game.remove_major_par_markers!
      fund!(game, major)
      round.instance_variable_set(:@current_operator, major)
      step.setup
    end

    def market_shares!(count = 2)
      shares = major.ipo_shares.first(count)
      game.share_pool.transfer_shares(Engine::ShareBundle.new(shares), game.share_pool)
      shares
    end

    def buy_share!(share = game.share_pool.shares_of(major).first)
      step.process_buy_shares(Engine::Action::BuyShares.new(major, shares: share))
    end

    def sell_share!(share = step.issuable_shares(major).first.shares.first)
      step.process_sell_shares(Engine::Action::SellShares.new(major, shares: share))
    end

    def abandon_minor!
      minor = start_minor!(game, 'C', game.players.last, 'UK')
      game.abandon_minor!(minor)
      minor
    end

    it 'allows successive share purchases without an abandoned minor' do
      shares = market_shares!
      cash = major.cash
      price = major.share_price.price
      buy_share!(shares.first)

      expect(step).not_to be_passed
      expect(step.actions(major)).to include('buy_shares', 'pass')
      buy_share!(shares.last)
      expect(major.cash).to eq(cash - (2 * price))
      expect(shares.map(&:owner)).to eq([major, major])
    end

    it 'blocks sales once share buying starts, before changing any assets' do
      market_shares!
      buy_share!
      share = major.ipo_shares.first
      state = [major.cash, game.bank.cash, major.share_price, share.owner]

      expect(step.actions(major)).not_to include('sell_shares')
      expect(step.issuable_shares(major)).to be_empty
      expect { sell_share!(share) }.to raise_error(Engine::GameError)
      expect([major.cash, game.bank.cash, major.share_price, share.owner]).to eq(state)
    end

    it 'blocks buying back stock after selling it' do
      market_shares!
      sell_share!
      state = [major.cash, game.bank.cash, major.share_price, game.share_pool.shares_of(major).dup]

      expect(step.actions(major)).not_to include('buy_shares')
      expect(step.redeemable_shares(major)).to be_empty
      expect { buy_share! }.to raise_error(Engine::GameError)
      expect([major.cash, game.bank.cash, major.share_price, game.share_pool.shares_of(major)]).to eq(state)
    end

    it 'pays the original share value for successive sales and moves DOWN per share' do
      price = major.share_price.price
      expected = major.share_price.coordinates
      2.times { expected = game.stock_market.down(major, expected) }
      cash = major.cash
      sell_share!

      expect(step).not_to be_passed
      expect(step.actions(major)).to include('sell_shares', 'pass')
      expect(step.issuable_shares(major).map(&:price_per_share).uniq).to eq([price])
      sell_share!
      expect(major.cash).to eq(cash + (2 * price))
      expect(major.share_price.coordinates).to eq(expected)
    end

    it 'allows an abandoned-minor purchase between successive share purchases' do
      shares = market_shares!
      minor = abandon_minor!
      buy_share!(shares.first)

      expect(step.actions(major)).to include('choose')
      step.process_choose(Engine::Action::Choose.new(major, choice: minor.id))
      expect(step.actions(major)).to include('buy_shares')
      expect(step.actions(major)).not_to include('sell_shares', 'choose')
      buy_share!(shares.last)
      expect(shares.map(&:owner)).to eq([major, major])
      expect { step.process_choose(Engine::Action::Choose.new(major, choice: minor.id)) }.to raise_error(Engine::GameError)
    end

    it 'resets the transaction direction for the next operator' do
      market_shares!
      buy_share!
      step.setup

      expect(step.actions(major)).to include('sell_shares', 'buy_shares')
      sell_share!
      step.setup
      expect(step.actions(major)).to include('buy_shares')
    end

    it 'does not offer share actions to another corporation' do
      other = game.corporation_by_id('GWR')
      expect(step.actions(other)).to be_empty
      expect { step.process_sell_shares(Engine::Action::SellShares.new(other, shares: major.ipo_shares.first)) }
        .to raise_error(Engine::GameError)
    end

    it 'rejects purchases that exceed treasury cash' do
      shares = market_shares!
      major.spend(major.cash, game.bank)

      expect(step.redeemable_shares(major)).to be_empty
      expect { buy_share!(shares.first) }.to raise_error(Engine::GameError)
      expect(shares.first.owner).to eq(game.share_pool)
    end

    it 'uses the market price regardless of the price supplied with a purchase' do
      share = market_shares!(1).first
      price = major.share_price.price
      cash = major.cash
      step.process_buy_shares(Engine::Action::BuyShares.new(major, shares: share, share_price: 1))

      expect(major.cash).to eq(cash - price)
    end

    it "only buys the major's own stock" do
      other = start_major!(game, 'GWR', game.players.last)
      share = other.ipo_shares.first
      game.share_pool.transfer_shares(share.to_bundle, game.share_pool)

      expect { buy_share!(share) }.to raise_error(Engine::GameError)
      expect(share.owner).to eq(game.share_pool)
    end

    it 'finishes automatically when no further share or minor purchase is affordable' do
      shares = market_shares!
      major.spend(major.cash - major.share_price.price, game.bank)
      buy_share!(shares.first)

      expect(step.actions(major)).to be_empty
      expect(step).to be_passed
    end

    it 'rejects sales beyond the Open Market limit' do
      market_shares!(5)
      share = major.ipo_shares.first

      expect(step.issuable_shares(major)).to be_empty
      expect { sell_share!(share) }.to raise_error(Engine::GameError)
      expect(share.owner).to eq(major)
    end
  end
end
