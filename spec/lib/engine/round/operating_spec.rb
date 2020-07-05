# frozen_string_literal: true

require './spec/spec_helper'

require 'engine/game/g_1889'
require 'engine/game/g_18_chesapeake'
require 'engine/phase'
require 'engine/round/operating'

module Engine
  describe Round::Operating do
    let(:players) { %w[a b] }
    let(:game) { Game::G1889.new(players) }
    let(:hex_j3) { game.hex_by_id('J3') }
    let(:hex_j5) { game.hex_by_id('J5') }
    let(:hex_k4) { game.hex_by_id('K4') }
    let(:hex_k6) { game.hex_by_id('K6') }
    let(:hex_k8) { game.hex_by_id('K8') }
    let(:hex_l7) { game.hex_by_id('L7') }

    let(:hex_e8) { game.hex_by_id('E8') }
    let(:hex_f7) { game.hex_by_id('F7') }
    let(:hex_f9) { game.hex_by_id('F9') }
    let(:hex_g8) { game.hex_by_id('G8') }
    let(:hex_g10) { game.hex_by_id('G10') }
    let(:hex_g12) { game.hex_by_id('G12') }
    let(:hex_g14) { game.hex_by_id('G14') }
    let(:hex_h11) { game.hex_by_id('H11') }
    let(:hex_h13) { game.hex_by_id('H13') }
    let(:hex_i12) { game.hex_by_id('I12') }
    let(:hex_c13) { game.hex_by_id('C13') }
    let(:player) { game.players.first }
    let(:player2) { game.players[1] }

    subject { Round::Operating.new([corporation], game: game, round_num: 1) }

    def fake_buy_train(train, corp)
      subject.depot.remove_train(train)
      corp.cash += train.price
      game.phase.process_action(Action::BuyTrain.new(corp, train: train, price: train.price))
      corp.buy_train(train, train.price)
    end

    before :each do
      game.stock_market.set_par(corporation, game.stock_market.par_prices[0])
      corporation.cash = 100
      corporation.owner = game.players.first
      allow(corporation).to receive(:floated?) { true }
    end

    context '#1889' do
      let(:corporation) { game.corporation_by_id('AR') }
      let(:corporation2) { game.corporation_by_id('SR') }
      subject do
        Round::Operating.new([corporation, corporation2], game: game, round_num: 1)
      end

      before :each do
        game.stock_market.set_par(corporation, game.stock_market.par_prices[0])
        game.stock_market.set_par(corporation2, game.stock_market.par_prices[0])
        game.send(:next_round!)

        corporation.cash = 1000
        corporation.owner = player
        corporation2.cash = 1000
        corporation2.owner = player
        player.cash = 2000
        player2.cash = 2000
        # Make player 1 president of two companies, player 2 have the same amount of shares
        4.times { game.share_pool.buy_shares(player, corporation.shares.first) }
        5.times { game.share_pool.buy_shares(player2, corporation.shares.first) }
        4.times { game.share_pool.buy_shares(player, corporation2.shares.first) }
        5.times { game.share_pool.buy_shares(player2, corporation2.shares.first) }
        player.cash = 2000
        player2.cash = 2000
        subject.process_action(Action::LayTile.new(corporation, tile: Tile.for('5'), hex: hex_k8, rotation: 3))
      end

      describe 'sellable_bundles' do
        it 'should not return bundles that cause a president change' do
          player.cash = 1
          corporation.cash = 1
          bundles = subject.sellable_bundles(player, corporation)
          # Player is president of corp 1, but cannot sell any shares without a president change
          expect(bundles.size).to eq(0)
          bundles = subject.sellable_bundles(player, corporation2)
          # Player is president of corp 2, but cannot sell any shares without a president change
          expect(bundles.size).to eq(0)
        end
      end

      describe 'buyable_trains' do
        it 'returns 2 trains in the depot at start' do
          available = subject.buyable_trains
          expect(available.size).to eq(1)
        end

        it 'returns a 2 train in the discard if discarded' do
          train = subject.buyable_trains.first
          fake_buy_train(train, corporation)
          subject.depot.reclaim_train(train)

          available = subject.buyable_trains
          expect(available.size).to eq(2)
        end

        it 'returns trains owned by other corporations' do
          train = subject.buyable_trains.first
          fake_buy_train(train, corporation2)

          available = subject.buyable_trains
          expect(available.size).to eq(2)
        end

        it 'returns only returns trains in the depot if the corp cannot afford and the player has sold shares' do
          train = subject.buyable_trains.first
          fake_buy_train(train, corporation2)
          corporation.cash = 1

          bundle = player.bundles_for_corporation(corporation2).first
          subject.process_action(Action::SellShares.new(
            player,
            shares: bundle.shares,
            share_price: bundle.price,
            percent: bundle.percent,
          ))
          available = subject.buyable_trains
          expect(available.size).to eq(1)
        end

        it 'returns only returns cheapest trains available if the corp cannot afford any' do
          while (train = subject.buyable_trains.first).name == '2'
            subject.depot.remove_train(train)
            corporation2.buy_train(train, train.price)
          end
          subject.depot.reclaim_train(corporation2.trains.first) while corporation2.trains.any?

          available = subject.buyable_trains
          expect(available.size).to eq(2)

          corporation.cash = 1
          available = subject.buyable_trains
          expect(available.size).to eq(1)
        end

        describe 'buy_train' do
          it 'allows purchasing with emergency funds if must buy' do
            expect(subject.must_buy_train?).to be true
            corporation.cash = 1
            train = subject.buyable_trains.first
            subject.process_action(Action::BuyTrain.new(corporation, train: train, price: train.price))
          end
          it 'does not allow purchasing with emergency funds if no need to buy' do
            train = subject.buyable_trains.first
            subject.process_action(Action::BuyTrain.new(corporation, train: train, price: train.price))
            expect(subject.must_buy_train?).to be false
            corporation.cash = 1
            train = subject.buyable_trains.first
            action = Action::BuyTrain.new(corporation, train: train, price: train.price)
            expect { subject.process_action(action) }.to raise_error GameError
          end
          it 'causes a rust event when buying the first 4' do
            train = subject.buyable_trains.first
            subject.process_action(Action::BuyTrain.new(corporation, train: train, price: train.price))
            expect(subject.must_buy_train?).to be false

            # Move to 4 trains to cause a rust event
            while (train = subject.buyable_trains.first).name != '4'
              fake_buy_train(train, corporation2)
            end

            corporation.cash = 1000
            train = subject.buyable_trains.first
            action = Action::BuyTrain.new(corporation, train: train, price: train.price)
            game.phase.process_action(action)
            subject.process_action(action)
            expect(corporation.trains.size).to eq(1)
          end

          it 'does not allow purchasing with emergency funds if no need to buy even if it causes a rusting' do
            train = subject.buyable_trains.first
            subject.process_action(Action::BuyTrain.new(corporation, train: train, price: train.price))
            expect(subject.must_buy_train?).to be false

            # Move to 4 trains to cause a rust event
            while (train = subject.buyable_trains.first).name != '4'
              fake_buy_train(train, corporation2)
            end

            train = subject.buyable_trains.first
            corporation2.buy_train(train, train.price)

            corporation.cash = 1
            train = subject.buyable_trains.first
            action = Action::BuyTrain.new(corporation, train: train, price: train.price)
            game.phase.process_action(action)
            expect { subject.process_action(action) }.to raise_error GameError
          end

          it 'does not allow EMR purchasing diesel when it can afford a 6' do
            # Allow diesels to be purchased
            while (train = subject.buyable_trains.first).name != '6'
              fake_buy_train(train, corporation2)
            end
            fake_buy_train(subject.buyable_trains.first, corporation2)

            corporation.cash = subject.buyable_trains.first.price
            train = subject.buyable_trains.find { |x| x.name == 'D' }
            action = Action::BuyTrain.new(corporation, train: train, price: train.price)
            game.phase.process_action(action)
            expect { subject.process_action(action) }.to raise_error GameError
          end
        end
      end
    end

    context '#18chesapeake' do
      let(:game) { Game::G18Chesapeake.new(players) }
      let(:corporation) { game.corporation_by_id('N&W') }
      let(:corporation2) { game.corporation_by_id('PRR') }
      subject do
        Round::Operating.new([corporation, corporation2], game: game, round_num: 1)
      end

      before :each do
        game.stock_market.set_par(corporation, game.stock_market.par_prices[0])
        game.stock_market.set_par(corporation2, game.stock_market.par_prices[0])
        game.send(:next_round!)

        corporation.cash = 1000
        corporation.owner = player
        corporation2.cash = 1000
        corporation2.owner = player
        player.cash = 2000
        player2.cash = 2000
        # Make player 1 president of two companies, player 2 have the same amount of shares
        4.times { game.share_pool.buy_shares(player, corporation.shares.first) }
        5.times { game.share_pool.buy_shares(player2, corporation.shares.first) }
        4.times { game.share_pool.buy_shares(player, corporation2.shares.first) }
        5.times { game.share_pool.buy_shares(player2, corporation2.shares.first) }
        player.cash = 2000
        player2.cash = 2000
        subject.process_action(Action::LayTile.new(corporation, tile: Tile.for('57'), hex: hex_c13, rotation: 1))
      end

      describe 'sellable_bundles' do
        it 'should return bundles that cause a president change' do
          player.cash = 1
          corporation.cash = 1
          expect(subject.current_entity).to eq(corporation)
          bundles = subject.sellable_bundles(player, corporation)
          # Player is president of corp 1, and it is the current corp
          expect(bundles.size).to eq(0)

          bundles = subject.sellable_bundles(player, corporation2)
          # Player is president of corp 2, selling shares will cause a president change
          # Only one share can sell to raise the 80 yen needed for a 2 train
          expect(bundles.size).to eq(1)
        end
      end

      describe 'buyable_trains' do
        it 'returns returns other corp trains if sold shares does not exceed face value' do
          train = subject.buyable_trains.first
          fake_buy_train(train, corporation2)
          corporation.cash = 1
          player.cash = 1

          bundle = player.bundles_for_corporation(corporation2).first
          subject.process_action(Action::SellShares.new(
            player,
            shares: bundle.shares,
            share_price: bundle.price,
            percent: bundle.percent,
          ))
          available = subject.buyable_trains
          expect(available.size).to eq(2)
        end
        it 'returns only depot trains if sold shares exceeds face value' do
          train = subject.buyable_trains.first
          fake_buy_train(train, corporation2)
          corporation.cash = 1
          player.cash = 1

          bundle = player.bundles_for_corporation(corporation2)[2]
          subject.process_action(Action::SellShares.new(
            player,
            shares: bundle.shares,
            share_price: bundle.price,
            percent: bundle.percent,
          ))
          available = subject.buyable_trains
          expect(available.size).to eq(1)
        end
      end

      describe 'buy_train' do
        it 'does not allow EMR purchasing diesel when it can afford a 6' do
          # Allow diesels to be purchased
          while (train = subject.buyable_trains.first).name != '6'
            fake_buy_train(train, corporation2)
          end
          fake_buy_train(subject.buyable_trains.first, corporation2)

          corporation.cash = subject.buyable_trains.first.price
          train = subject.buyable_trains.find { |x| x.name == 'D' }
          action = Action::BuyTrain.new(corporation, train: train, price: train.price)
          game.phase.process_action(action)
          expect { subject.process_action(action) }.to raise_error GameError
        end

        it 'allows purchasing another players train' do
          fake_buy_train(subject.buyable_trains.first, corporation2)

          corporation.cash = 1
          train = corporation2.trains.first
          player.cash = train.price
          action = Action::BuyTrain.new(corporation, train: train, price: train.price)
          game.phase.process_action(action)
          subject.process_action(action)
        end
        it 'does not allow purchasing another players train for above price' do
          fake_buy_train(subject.buyable_trains.first, corporation2)

          corporation.cash = 1
          train = corporation2.trains.first
          player.cash = train.price
          action = Action::BuyTrain.new(corporation, train: train, price: train.price + 1)
          game.phase.process_action(action)
          expect { subject.process_action(action) }.to raise_error GameError
        end
      end
    end

    describe '#connected_hexes' do
      context 'with awa' do
        let(:corporation) { game.corporation_by_id('AR') }

        it 'returns the layable hexes' do
          expect(subject.connected_hexes).to eq(
            hex_k8 => [1, 2, 3, 4]
          )

          subject.process_action(Action::LayTile.new(corporation, tile: Tile.for('5'), hex: hex_k8, rotation: 3))

          expect(subject.connected_hexes).to eq(
            hex_k6 => [0],
            hex_k8 => [1, 2, 3, 4],
            hex_l7 => [1],
          )

          subject.process_action(Action::LayTile.new(corporation, tile: Tile.for('9'), hex: hex_k6, rotation: 0))

          expect(subject.connected_hexes).to eq(
            hex_j3 => [5],
            hex_j5 => [4],
            hex_k4 => [0, 1, 2],
            hex_k6 => [0, 3],
            hex_k8 => [1, 2, 3, 4],
            hex_l7 => [1],
          )
        end
      end

      context 'with tse' do
        let(:corporation) { game.corporation_by_id('TR') }

        it 'can handle forks' do
          subject.process_action(Action::LayTile.new(corporation, tile: Tile.for('58'), hex: hex_g10, rotation: 0))
          subject.process_action(Action::LayTile.new(corporation, tile: Tile.for('57'), hex: hex_g12, rotation: 0))
          subject.phase.next!
          subject.process_action(Action::LayTile.new(corporation, tile: Tile.for('15'), hex: hex_g12, rotation: 3))
          subject.process_action(Action::LayTile.new(corporation, tile: Tile.for('9'), hex: hex_h13, rotation: 1))

          expect(subject.connected_hexes).to eq(
            hex_e8 => [5],
            hex_f7 => [0],
            hex_f9 => [2, 3, 4, 5],
            hex_g8 => [1],
            hex_g10 => [2, 0],
            hex_g12 => [3, 4, 5, 0],
            hex_g14 => [3, 4],
            hex_h11 => [1],
            hex_h13 => [2, 1, 4],
            hex_i12 => [1],
          )
        end
      end

      context 'with ko' do
        let(:corporation) { game.corporation_by_id('KO') }
        let(:company) { game.company_by_id('TR') }
        let(:player) { game.player_by_id('a') }

        it 'errors when upgrading K4 if Takumatsu is owned by player' do
          company.owner = player
          player.companies << company

          action = Action::LayTile.new(corporation, tile: Tile.for('440'), hex: hex_k4, rotation: 0)
          expect { subject.process_action(action) }.to raise_error(GameError)
        end

        it 'allows upgrading K4 if Takumatsu is owned by any corporation' do
          company.owner = corporation
          corporation.companies << company
          subject.phase.next!
          subject.process_action(Action::LayTile.new(corporation, tile: Tile.for('440'), hex: hex_k4, rotation: 0))
        end
      end
    end
  end
end
