# frozen_string_literal: true

require './spec/spec_helper'
require 'engine/game/g_1828'

module Engine
  describe Game::G1828 do
    let(:players) { %w[a b c] }
    let(:game) { Game::G1828.new(players) }
    let(:player_1) { game.players.first }
    let(:corporation) { game.corporations.first }
    let(:stock_market) { game.stock_market }
    let(:phase) { game.phase }

    def next_round!
      game.send(:next_round!)
      game.round.setup
    end

    def next_or!
      loop do
        next_round!
        break if game.round.is_a?(Round::Operating)
      end
      game.round
    end

    describe 'events' do
      it 'should be unlocked by game phase' do
        expect(stock_market.par_prices.size).to eq(3)
        expect(stock_market.par_prices.map(&:price)).to include(67, 71, 79)

        phase.buying_train!(corporation, game.trains.find { |t| t.name == '3' })
        expect(stock_market.par_prices.size).to eq(5)
        expect(stock_market.par_prices.map(&:price)).to include(67, 71, 79, 86, 94)

        phase.buying_train!(corporation, game.trains.find { |t| t.name == '5' })
        expect(stock_market.par_prices.size).to eq(6)
        expect(stock_market.par_prices.map(&:price)).to include(67, 71, 79, 86, 94, 105)

        phase.buying_train!(corporation, game.trains.find { |t| t.name == '3+D' })
        expect(stock_market.par_prices.size).to eq(7)
        expect(stock_market.par_prices.map(&:price)).to include(67, 71, 79, 86, 94, 105, 120)
      end

      it 'should remove unparred corporations at purple phase' do
        player_1.cash = 10_000
        stock_market.set_par(corporation, stock_market.par_prices.first)
        5.times { game.share_pool.buy_shares(player_1, corporation.shares.first) }

        erie = game.corporations.find { |c| c.name == 'ERIE' }
        erie_home_tile = game.hex_by_id(erie.coordinates).tile

        next_or!
        phase.buying_train!(corporation, game.trains.find { |t| t.name == 'D' })
        expect(game.corporations.size).to be(1)
        expect(game.corporations.first).to eq(corporation)
        expect(erie_home_tile.cities[0].available_slots).to eq(0)
        expect(erie_home_tile.cities[1].available_slots).to eq(0)
      end

      it 'should trigger end game at purple phase' do
        player_1.cash = 10_000
        stock_market.set_par(corporation, stock_market.par_prices.first)
        5.times { game.share_pool.buy_shares(player_1, corporation.shares.first) }

        next_or!
        %w[3 5 3+D 6 8E D].each do |train_name|
          phase.buying_train!(corporation, game.trains.find { |t| t.name == train_name })
        end
        expect(game.custom_end_game_reached?).to be_truthy
      end
    end

    context 'VA Coalfields' do
      let(:ic) { game.corporations.find { |corp| corp.name == 'IC' } }
      let(:co) { game.corporations.find { |corp| corp.name == 'C&O' } }
      let(:va_tile) { game.hex_by_id('K11').tile }

      it 'should block unless coal marker purchased' do
        player_1.cash = 10_000
        stock_market.set_par(ic, stock_market.par_prices.first)
        5.times { game.share_pool.buy_shares(player_1, ic.shares.first) }

        next_or!
        game.round.process_action(
          Engine::Action::LayTile.new(ic, tile: game.tile_by_id('9-1'), hex: game.hex_by_id('J8'), rotation: 1)
        )

        next_or!
        expect(game.round.actions_for(ic)).to_not include('buy_special')
        game.round.process_action(
          Engine::Action::LayTile.new(ic, tile: game.tile_by_id('8-2'), hex: game.hex_by_id('J10'), rotation: 5)
        )
        expect do
          game.round.process_action(Engine::Action::PlaceToken.new(ic, city: va_tile.cities.first, slot: 0))
        end.to raise_error GameError

        next_or!
        expect(game.graph.connected_hexes(ic).include?(game.hex_by_id('J12'))).to be_falsey
        expect(game.graph.connected_hexes(ic).include?(game.hex_by_id('K13'))).to be_falsey
        expect(game.round.actions_for(ic)).to include('buy_special')

        item = game.round.step_for(ic, 'buy_special').items.first
        game.round.process_action(Engine::Action::BuySpecial.new(ic, item: item))
        expect(game.coal_marker?(ic)).to be_truthy
        expect(va_tile.icons.count { |icon| icon.name == 'coal' }).to eq(1)
        expect(game.graph.connected_hexes(ic).include?(game.hex_by_id('J12'))).to be_truthy
        expect(game.graph.connected_hexes(ic).include?(game.hex_by_id('K13'))).to be_truthy

        game.round.process_action(
          Engine::Action::LayTile.new(ic, tile: game.tile_by_id('4-0'), hex: game.hex_by_id('K13'), rotation: 1)
        )
        expect(va_tile.icons.count { |icon| icon.name == 'coal' }).to eq(2)
        expect do
          game.round.process_action(Engine::Action::PlaceToken.new(ic, city: va_tile.cities.first, slot: 0))
        end.to raise_error GameError
      end

      it 'should acquire coal marker when laying VA tunnel' do
        player_1.cash = 10_000
        stock_market.set_par(co, stock_market.par_prices.first)
        5.times { game.share_pool.buy_shares(player_1, co.shares.first) }

        next_or!
        game.round.process_action(
          Engine::Action::LayTile.new(co, tile: game.tile_by_id('57-0'), hex: game.hex_by_id('K15'), rotation: 1)
        )
        expect(game.coal_marker?(co)).to be_falsey

        next_or!
        game.round.process_action(
          Engine::Action::LayTile.new(co, tile: game.tile_by_id('4-0'), hex: game.hex_by_id('K13'), rotation: 1)
        )
        expect(game.coal_marker?(co)).to be_truthy
      end
    end
  end
end
