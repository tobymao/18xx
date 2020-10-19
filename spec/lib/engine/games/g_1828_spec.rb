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
        expect(erie_home_tile.cities[0].tokened_by?(erie)).to be_truthy
        expect(erie_home_tile.cities[1].tokened_by?(erie)).to be_truthy
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
  end
end
