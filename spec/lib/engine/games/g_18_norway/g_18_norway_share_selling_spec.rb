# frozen_string_literal: true

require 'find'
require './spec/spec_helper'
require 'json'

module Engine
  describe Game::G18Norway do
    let(:players) { %w[a b c] }

    let(:game_file) do
      Find.find(FIXTURES_DIR).find { |f| File.basename(f) == "#{game_file_name}.json" }
    end

    let(:id_first_index_by_action_type) do
      file = File.open(game_file)
      data = JSON.parse(file.read)
      file.close
      data['actions'].each do |action|
        return action['id'] - 1 if action['type'] == first_action_type
      end
      1
    end

    context '18Norway share selling' do
      let(:game_file_name) { '18_norway_buy_ship' }
      let(:first_action_type) { 'sell_shares' }

      it 'Should not allow selling president\'s share if NSB would become president' do
        game = Engine::Game.load(game_file, at_action: id_first_index_by_action_type)
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
        end.to raise_error(GameError, 'Cannot sell shares as NSB would become president')
      end

      it 'Should allow selling president\'s share if another player has 20%' do
        game = Engine::Game.load(game_file, at_action: id_first_index_by_action_type)
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

      it 'Should not allow selling president\'s share if no other player has 20%' do
        game = Engine::Game.load(game_file, at_action: id_first_index_by_action_type)
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
        expect { game.sell_shares_and_change_price(bundle) }.to raise_error(GameError)
      end

      it 'Should allow selling non-president shares' do
        game = Engine::Game.load(game_file, at_action: id_first_index_by_action_type)
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
