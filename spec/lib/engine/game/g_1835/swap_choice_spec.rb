# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1835::Game do
  describe 'swap_choice' do
    it 'asks the old president of the PR if he wants to swap and leaves shares as is on denial' do
      game = fixture_at_action(630)

      prussian = game.corporation_by_id('PR')
      player_1 = game.player_by_id(0)
      player_3 = game.player_by_id(2)

      # It's Player 3's turn and they have the opportunity to take away the presidency. Also, Player 3 has 4 half shares
      expect(game.current_entity).to eq player_3
      expect(prussian.owner).to eq player_1
      expect(player_1.percent_of(prussian)).to be 40
      expect(player_3.percent_of(prussian)).to be 40
      expect(player_3.shares_of(prussian).count { |share| share.percent == 5 }).to be 4

      pool_shares = game.share_pool.shares_by_corporation[prussian]
      game.process_action(Engine::Action::BuyShares.new(player_3,
                                                        shares: pool_shares.find(&:buyable))).maybe_raise!
      expect(player_3.percent_of(prussian)).to be 50

      expect(game.current_entity).to eq player_1
      expect(game.round.active_step).to be_a(Engine::Game::G1835::Step::SwapChoice)
      game.process_action(Engine::Action::Choose.new(game.current_entity, choice: 'Keep one 10% cert')).maybe_raise!
      expect(player_1.shares_of(prussian).count { |share| share.percent == 5 }).to be 0
      expect(player_1.percent_of(prussian)).to be 40
      expect(player_3.shares_of(prussian).count { |share| share.percent == 5 }).to be 4
      expect(player_3.percent_of(prussian)).to be 50
    end

    it 'asks the old president of the PR if he wants to swap and gives them to shares shares as is on accepting' do
      game = fixture_at_action(630)

      prussian = game.corporation_by_id('PR')
      player_1 = game.player_by_id(0)
      player_3 = game.player_by_id(2)

      # It's Player 3's turn and they have the opportunity to take away the presidency. Also, Player 3 has 4 half shares
      expect(game.current_entity).to eq player_3
      expect(prussian.owner).to eq player_1
      expect(player_1.percent_of(prussian)).to be 40
      expect(player_3.percent_of(prussian)).to be 40
      expect(player_3.shares_of(prussian).count { |share| share.percent == 5 }).to be 4

      pool_shares = game.share_pool.shares_by_corporation[prussian]
      game.process_action(Engine::Action::BuyShares.new(player_3,
                                                        shares: pool_shares.find(&:buyable))).maybe_raise!
      expect(player_3.percent_of(prussian)).to be 50

      expect(game.current_entity).to eq player_1
      expect(game.round.active_step).to be_a(Engine::Game::G1835::Step::SwapChoice)
      game.process_action(Engine::Action::Choose.new(game.current_entity, choice: 'Swap for two 5% certs')).maybe_raise!
      expect(player_1.shares_of(prussian).count { |share| share.percent == 5 }).to be 2
      expect(player_1.percent_of(prussian)).to be 40
      expect(player_3.shares_of(prussian).count { |share| share.percent == 5 }).to be 2
      expect(player_3.percent_of(prussian)).to be 50
    end

    it 'does not ask the PR old president to swap if the new president does not have two shares to trade for the president' do
      game = fixture_at_action(625)

      prussian = game.corporation_by_id('PR')
      player_1 = game.player_by_id(0)
      player_3 = game.player_by_id(2)
      expect(prussian.owner).to eq player_3
      expect(player_3.shares_of(prussian).count { |share| share.percent == 5 }).to be 4

      pool_shares = game.share_pool.shares_by_corporation[prussian]
      game.process_action(Engine::Action::BuyShares.new(player_1,
                                                        shares: pool_shares.find(&:buyable))).maybe_raise!
      expect(game.current_entity).to eq player_1
      expect(prussian.owner).to eq player_1
      expect(player_3.shares_of(prussian).count { |share| share.percent == 5 }).to be 4
      expect(game.round.active_step).to be_a(Engine::Step::BuySellParShares)
    end

    it 'asks the old president of the BA if he wants to swap and leaves shares as is on denial' do
      game = fixture_at_action(540)

      baden = game.corporation_by_id('BA')
      player_2 = game.player_by_id(1)
      player_3 = game.player_by_id(2)

      expect(baden.owner).to eq player_3
      # Both players have 20% + 10% + 10% = 40%
      expect(player_2.percent_of(baden)).to be 40
      expect(player_3.percent_of(baden)).to be 40
      expect(player_2.certs_of(baden).size).to be 3
      expect(player_3.certs_of(baden).size).to be 3

      bundle = game.sellable_bundles(player_3, baden).find { |b| b.percent == 10 }
      game.process_action(Engine::Action::SellShares.new(player_3, shares: bundle.shares)).maybe_raise!

      expect(baden.owner).to eq player_2
      expect(game.round.active_step).to be_a(Engine::Game::G1835::Step::SwapChoice)
      game.process_action(Engine::Action::Choose.new(game.current_entity, choice: 'Keep one 20% cert')).maybe_raise!

      expect(player_2.percent_of(baden)).to be 40
      expect(player_3.percent_of(baden)).to be 30
      expect(player_2.certs_of(baden).size).to be 3
      expect(player_3.certs_of(baden).size).to be 2
    end

    it 'asks the old president of the BA if he wants to swap and gives them to shares shares as is on accepting' do
      game = fixture_at_action(540)

      baden = game.corporation_by_id('BA')
      player_2 = game.player_by_id(1)
      player_3 = game.player_by_id(2)

      expect(baden.owner).to eq player_3
      # Both players have 20% + 10% + 10% = 40%
      expect(player_2.percent_of(baden)).to be 40
      expect(player_3.percent_of(baden)).to be 40
      expect(player_2.certs_of(baden).size).to be 3
      expect(player_3.certs_of(baden).size).to be 3

      bundle = game.sellable_bundles(player_3, baden).find { |b| b.percent == 10 }
      game.process_action(Engine::Action::SellShares.new(player_3, shares: bundle.shares)).maybe_raise!

      expect(baden.owner).to eq player_2
      expect(game.round.active_step).to be_a(Engine::Game::G1835::Step::SwapChoice)
      game.process_action(Engine::Action::Choose.new(game.current_entity, choice: 'Swap for two 10% certs')).maybe_raise!

      expect(player_2.percent_of(baden)).to be 40
      expect(player_3.percent_of(baden)).to be 30
      # Player 2 ends up with two 20% shares, one being the president share
      expect(player_2.certs_of(baden).size).to be 2
      expect(player_3.certs_of(baden).size).to be 3
    end
  end
end
