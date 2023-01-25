# frozen_string_literal: true

require './spec/spec_helper'

module Engine
  describe Game::G1828::Game do
    let(:players) { %w[a b c] }
    let(:game) { Game::G1828::Game.new(players) }
    let(:player_1) { game.players.first }
    let(:corporation) { game.corporations.first }
    let(:stock_market) { game.stock_market }
    let(:phase) { game.phase }

    def next_round!
      loop do
        game.send(:next_round!)
        game.round.setup
        break if yield
      end
      game.round
    end

    def next_or!
      next_round! { game.round.is_a?(Round::Operating) }
    end

    def next_sr!
      next_round! { game.round.is_a?(Round::Stock) }
    end

    def find_train(train_name)
      game.trains.find { |t| t.name == train_name }
    end

    describe 'events' do
      it 'should be unlocked by game phase' do
        expect(game.par_prices.size).to eq(3)
        expect(game.par_prices.map(&:price)).to include(67, 71, 79)

        phase.buying_train!(corporation, find_train('3'), find_train('3').owner)
        expect(game.par_prices.size).to eq(5)
        expect(game.par_prices.map(&:price)).to include(67, 71, 79, 86, 94)

        phase.buying_train!(corporation, find_train('5'), find_train('5').owner)
        expect(game.par_prices.size).to eq(6)
        expect(game.par_prices.map(&:price)).to include(67, 71, 79, 86, 94, 105)

        phase.buying_train!(corporation, find_train('3+D'), find_train('3+D').owner)
        expect(game.par_prices.size).to eq(7)
        expect(game.par_prices.map(&:price)).to include(67, 71, 79, 86, 94, 105, 120)
      end

      it 'should remove unparred corporations at purple phase' do
        player_1.cash = 10_000
        stock_market.set_par(corporation, game.par_prices.first)
        5.times { game.share_pool.buy_shares(player_1, corporation.shares.first) }

        erie = game.corporations.find { |c| c.name == 'ERIE' }
        erie_home_tile = game.hex_by_id(erie.coordinates).tile

        next_or!
        loop do
          train = game.trains.shift
          phase.buying_train!(corporation, train, train.owner)
          break if train.name == 'D'
        end
        next_sr!
        expect(game.corporations.size).to be(1)
        expect(game.corporations.first).to eq(corporation)
        expect(erie_home_tile.cities[0].available_slots).to eq(0)
        expect(erie_home_tile.cities[1].available_slots).to eq(0)
      end
    end

    context 'VA Coalfields' do
      let(:ic) { game.corporations.find { |corp| corp.name == 'IC' } }
      let(:co) { game.corporations.find { |corp| corp.name == 'C&O' } }
      let(:va_tile) { game.hex_by_id('K11').tile }

      it 'should block unless coal marker purchased' do
        player_1.cash = 10_000
        stock_market.set_par(ic, game.par_prices.first)
        5.times { game.share_pool.buy_shares(player_1, ic.shares.first) }

        next_or!
        game.round.process_action(
          Engine::Action::LayTile.new(ic, tile: game.tile_by_id('9-1'), hex: game.hex_by_id('J8'), rotation: 1)
        )

        next_or!
        expect(game.round.actions_for(ic)).to_not include('special_buy')
        game.round.process_action(
          Engine::Action::LayTile.new(ic, tile: game.tile_by_id('8-2'), hex: game.hex_by_id('J10'), rotation: 5)
        )
        expect do
          game.round.process_action(Engine::Action::PlaceToken.new(ic, city: va_tile.cities.first, slot: 0))
        end.to raise_error GameError

        next_or!
        expect(game.graph.connected_hexes(ic).include?(game.hex_by_id('J12'))).to be_falsey
        expect(game.graph.connected_hexes(ic).include?(game.hex_by_id('K13'))).to be_falsey
        expect(game.round.actions_for(ic)).to include('special_buy')

        item = game.round.step_for(ic, 'special_buy').coal_marker
        game.round.process_action(Engine::Action::SpecialBuy.new(ic, item: item))
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
        stock_market.set_par(co, game.par_prices.first)
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
