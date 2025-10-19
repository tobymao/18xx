# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G18Norway::Game do
  describe '18_norway_buy_ship' do
    context '18Norway buy ship' do
      let(:first_train_buy_action) { 15 }

      it 'Should not show ships when corporation must buy a train' do
        game = fixture_at_action(first_train_buy_action, clear_cache: true)

        corporation = game.current_entity

        # Force corporation to have no trains
        corporation.trains.clear
        # Remove ignore mandatory train ability
        corporation.remove_ability(game.abilities(corporation, :ignore_mandatory_train))

        step = game.round.active_step
        available = step.buyable_trains(corporation)
        ships = available.select { |train| game.ship?(train) }
        expect(ships.size).to eq(0)
      end

      it 'Should show ships when corporation must buy a train with ignore mandatory train ability' do
        game = fixture_at_action(first_train_buy_action, clear_cache: true)

        corporation = game.current_entity

        # Force corporation to have no trains
        corporation.trains.clear

        # Add ignore mandatory train ability
        corporation.add_ability(Engine::Ability::Base.new(
          type: 'ignore_mandatory_train',
          description: 'Not mandatory to own a train',
        ))

        step = game.round.active_step
        available = step.buyable_trains(corporation)
        ships = available.select { |train| game.ship?(train) }
        expect(ships.size).to eq(1)
      end

      it 'Should show ships when corporation has trains but cannot afford next train' do
        game = fixture_at_action(first_train_buy_action, clear_cache: true)

        corporation = game.current_entity

        # Give corporation a train enough money to buy next ship but not enough cash for next train
        corporation.trains << game.depot.upcoming.first
        corporation.set_cash(150, game.bank) # Less than cheapest train price but enough to buy ship
        game.depot.export_all!('2', silent: true) # Export 2 trains so corporation can afford next train

        step = game.round.active_step
        available = step.buyable_trains(corporation)
        ships = available.select { |train| game.ship?(train) }
        expect(ships.size).to be > 0
      end

      it 'Should not show ships that corporation already owns' do
        game = fixture_at_action(first_train_buy_action, clear_cache: true)

        corporation = game.current_entity

        # Give corporation a ship
        ship = game.depot.upcoming.find { |t| game.ship?(t) }
        corporation.trains << ship

        step = game.round.active_step
        available = step.buyable_trains(corporation)
        duplicate_ships = available.select { |train| game.ship?(train) && train.name == ship.name }
        expect(duplicate_ships.size).to eq(0)
      end
    end

    context 'Hovebanen' do
      it 'cash should match the auction price' do
        game = fixture_at_action(7)

        expect(game.players.map(&:cash)).to eq([300, 190, 240])
        expect(game.hovedbanen.cash).to eq(170)
        expect(game.hovedbanen.shares[0].price).to eq(80)
      end
    end

    context 'share selling' do
      let(:action) { 1 }

      it "Should not allow selling president's share if NSB would become president" do
        game = fixture_at_action(action, clear_cache: true)

        corporation = game.corporations.find { |c| c != game.nsb }

        # Ensure corporation has a share price
        share_price = game.stock_market.par_prices.first
        game.stock_market.set_par(corporation, share_price)

        # Give NSB enough shares to become president if current president sells
        shares = game.shares.select { |s| s.corporation == corporation }.take(2)
        game.share_pool.transfer_shares(
          Engine::ShareBundle.new(shares),
          game.nsb
        )

        # Try to sell president's share
        bundle = Engine::ShareBundle.new(game.shares.select { |s| s.corporation == corporation && s.president })
        expect do
          game.sell_shares_and_change_price(bundle)
        end.to raise_error(Engine::GameError, 'Cannot sell shares as NSB would become president')
      end

      it "Should allow selling president's share if another player has 20%" do
        game = fixture_at_action(action, clear_cache: true)

        corporation = game.corporations.find { |c| c != game.nsb }
        other_player = game.players[1]

        # Ensure corporation has a share price
        share_price = game.stock_market.par_prices.first
        game.stock_market.set_par(corporation, share_price)

        # Give NSB enough shares to become president if current president sells
        shares = game.shares.select { |s| s.corporation == corporation }.take(2)
        game.share_pool.transfer_shares(
          Engine::ShareBundle.new(shares),
          game.nsb
        )

        # Give other player 20% shares
        shares = game.shares.select { |s| s.corporation == corporation }.take(2)
        game.share_pool.transfer_shares(
          Engine::ShareBundle.new(shares),
          other_player
        )

        # Try to sell president's share
        bundle = Engine::ShareBundle.new(game.shares.select { |s| s.corporation == corporation && s.president })
        expect { game.sell_shares_and_change_price(bundle) }.not_to raise_error
      end

      it "Should not allow selling president's share if no other player has 20%" do
        game = fixture_at_action(action, clear_cache: true)

        corporation = game.corporations.find { |c| c != game.nsb }
        other_player = game.players[1]

        # Ensure corporation has a share price
        share_price = game.stock_market.par_prices.first
        game.stock_market.set_par(corporation, share_price)

        # Give NSB enough shares to become president if current president sells
        shares = game.shares.select { |s| s.corporation == corporation }.take(2)
        game.share_pool.transfer_shares(
          Engine::ShareBundle.new(shares),
          game.nsb
        )

        # Give other player only 10% shares
        shares = game.shares.select { |s| s.corporation == corporation }.take(1)
        game.share_pool.transfer_shares(
          Engine::ShareBundle.new(shares),
          other_player
        )

        # Try to sell president's share
        bundle = Engine::ShareBundle.new(game.shares.select { |s| s.corporation == corporation && s.president })
        expect { game.sell_shares_and_change_price(bundle) }.to raise_error(Engine::GameError)
      end

      it 'Should allow selling non-president shares' do
        game = fixture_at_action(action, clear_cache: true)

        corporation = game.corporations.find { |c| c != game.nsb }

        # Ensure corporation has a share price
        share_price = game.stock_market.par_prices.first
        game.stock_market.set_par(corporation, share_price)

        # Try to sell non-president share
        bundle = Engine::ShareBundle.new(game.shares.select { |s| s.corporation == corporation && !s.president })
        expect { game.sell_shares_and_change_price(bundle) }.not_to raise_error
      end
    end
  end
end
