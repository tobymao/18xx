# frozen_string_literal: true

require './spec/spec_helper'

RSpec::Matchers.define :be_assigned_to do |expected|
  match do |actual|
    expected.assigned?(actual.id)
  end
end

module Engine
  describe Round::Operating do
    let(:players) { %w[a b c] }
    let(:game) { Game::G1889::Game.new(players) }
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

    subject { move_to_or! }

    def next_round!
      game.send(:next_round!)
      game.round.setup
    end

    def move_to_or!
      # Move the game into an OR

      next_round! until game.round.is_a?(Round::Operating)

      game.round
    end

    def goto_new_or!
      next_round!
      move_to_or!
    end

    def goto_train_step!
      # skip past non train-buying actions
      until subject.active_step.is_a?(Engine::Step::Train)
        action = Action::Pass.new(subject.current_entity)
        subject.process_action(action)
      end
    end

    def fake_buy_train(train, corp)
      corp.trains.slice!(2)
      source = train.owner
      game.depot.remove_train(train)
      corp.cash += train.price
      game.phase.buying_train!(corp, train, source)
      game.buy_train(corp, train, train.price)
    end

    def real_buy_depot_train(corporation, variant)
      train = subject.active_step
                .buyable_trains(corporation)
                .find(&:from_depot?)
      price = train.variants[variant][:price]
      action = Action::BuyTrain.new(corporation, train: train, price: price, variant: variant)
      subject.process_action(action)
    end

    def remove_trains_until!(train)
      until (t = game.depot.depot_trains.first).name == train
        game.depot.remove_train(t)
      end
      t
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
      let(:ehime) { game.company_by_id('ER') }
      subject { move_to_or! }

      before :each do
        game.stock_market.set_par(corporation, game.stock_market.par_prices[0])
        game.stock_market.set_par(corporation2, game.stock_market.par_prices[0])
        next_round!

        corporation.cash = 1000
        corporation.owner = player
        corporation2.cash = 1000
        corporation2.owner = player
        player.cash = 2000
        player2.cash = 2000
        # Make player 1 president of two companies, player 2 have the same amount of shares
        4.times { game.share_pool.buy_shares(player, corporation.shares.first) }
        5.times { game.share_pool.buy_shares(player2, corporation.shares.first) }
        3.times { game.share_pool.buy_shares(player, corporation2.shares.first) }
        4.times { game.share_pool.buy_shares(player2, corporation2.shares.first) }
        player.cash = 2000
        player2.cash = 2000
        subject.process_action(Action::LayTile.new(corporation, tile: Tile.for('5'), hex: hex_k8, rotation: 3))
      end

      describe 'sellable_bundles' do
        it 'should not return bundles that cause a president change' do
          player.cash = 1
          corporation.cash = 1
          bundles = game.sellable_bundles(player, corporation)
          # Player is president of corp 1, but cannot sell any shares without a president change
          expect(bundles.size).to eq(0)
          bundles = game.sellable_bundles(player, corporation2)
          # Player is president of corp 2, but cannot sell any shares without a president change
          expect(bundles.size).to eq(0)
        end
      end

      describe 'buyable_trains' do
        it 'returns 2 trains in the depot at start' do
          available = subject.active_step.buyable_trains(corporation)
          expect(available.size).to eq(1)
        end

        it 'returns a 2 train in the discard if discarded' do
          train = subject.active_step.buyable_trains(corporation).first
          fake_buy_train(train, corporation)
          game.depot.reclaim_train(train)

          available = subject.active_step.buyable_trains(corporation)
          expect(available.size).to eq(2)
        end

        it 'returns trains owned by other corporations' do
          train = subject.active_step.buyable_trains(corporation).first
          fake_buy_train(train, corporation2)

          available = subject.active_step.buyable_trains(corporation)
          expect(available.size).to eq(2)
        end

        it 'returns only returns trains in the depot if the corp cannot afford and the player has sold shares' do
          train = subject.active_step.buyable_trains(corporation).first
          fake_buy_train(train, corporation2)
          # Ensure we can sell shares.
          game.share_pool.buy_shares(player, corporation2.shares.first)
          corporation.cash = 1
          player.cash = 1

          bundle = game.bundles_for_corporation(player, corporation2).first
          subject.process_action(Action::SellShares.new(
            player,
            shares: bundle.shares,
            share_price: bundle.price_per_share,
            percent: bundle.percent,
          ))
          available = subject.active_step.buyable_trains(corporation)
          expect(available.size).to eq(1)
        end

        it 'returns only returns cheapest trains available if the corp cannot afford any' do
          while (train = subject.active_step.buyable_trains(corporation).first).name == '2'
            game.depot.remove_train(train)
            game.buy_train(corporation2, train, train.price)
          end
          game.depot.reclaim_train(corporation2.trains.first) while corporation2.trains.any?

          available = subject.active_step.buyable_trains(corporation)
          expect(available.size).to eq(2)

          corporation.cash = 1
          available = subject.active_step.buyable_trains(corporation)
          expect(available.size).to eq(1)
        end

        describe 'buy_train' do
          it 'allows purchasing with emergency funds if must buy' do
            expect(subject.active_step.must_buy_train?(corporation)).to be true
            corporation.cash = 1
            train = subject.active_step.buyable_trains(corporation).first
            subject.process_action(Action::BuyTrain.new(corporation, train: train, price: train.price))
          end
          it 'does not allow purchasing with emergency funds if no need to buy' do
            train = subject.active_step.buyable_trains(corporation).first
            subject.process_action(Action::BuyTrain.new(corporation, train: train, price: train.price))
            expect(subject.active_step.must_buy_train?(corporation)).to be false
            corporation.cash = 1
            train = subject.active_step.buyable_trains(corporation).first
            action = Action::BuyTrain.new(corporation, train: train, price: train.price)
            expect { subject.process_action(action) }.to raise_error GameError
          end
          it 'causes a rust event when buying the first 4' do
            train = subject.active_step.buyable_trains(corporation).first
            subject.process_action(Action::BuyTrain.new(corporation, train: train, price: train.price))
            expect(subject.active_step.must_buy_train?(corporation)).to be false

            # Move to 4 trains to cause a rust event
            while (train = subject.active_step.buyable_trains(corporation).first).name != '4'
              fake_buy_train(train, corporation2)
            end

            corporation.cash = 1000
            train = subject.active_step.buyable_trains(corporation).first
            action = Action::BuyTrain.new(corporation, train: train, price: train.price)
            subject.process_action(action)
            expect(corporation.trains.size).to eq(1)
          end

          it 'does not allow purchasing with emergency funds if no need to buy even if it causes a rusting' do
            train = subject.active_step.buyable_trains(corporation).first
            subject.process_action(Action::BuyTrain.new(corporation, train: train, price: train.price))
            expect(subject.active_step.must_buy_train?(corporation)).to be false

            # Move to 4 trains to cause a rust event
            while (train = subject.active_step.buyable_trains(corporation).first).name != '4'
              fake_buy_train(train, corporation2)
            end

            train = subject.active_step.buyable_trains(corporation).first
            game.buy_train(corporation2, train, train.price)

            corporation.cash = 1
            train = subject.active_step.buyable_trains(corporation).first
            action = Action::BuyTrain.new(corporation, train: train, price: train.price)
            fake_buy_train(train, corporation)
            expect { subject.process_action(action) }.to raise_error GameError
          end

          it 'does not allow EMR purchasing diesel when it can afford a 6' do
            # Allow diesels to be purchased
            while (train = subject.active_step.buyable_trains(corporation).first).name != '6'
              fake_buy_train(train, corporation2)
            end
            fake_buy_train(subject.active_step.buyable_trains(corporation).first, corporation2)

            corporation.cash = subject.active_step.buyable_trains(corporation).first.price
            train = subject.active_step.buyable_trains(corporation).find { |t| t.name == 'D' }
            action = Action::BuyTrain.new(corporation, train: train, price: train.price)
            fake_buy_train(train, corporation)
            expect { subject.process_action(action) }.to raise_error GameError
          end

          describe 'bankruptcy' do
            let(:corporation3) { game.corporation_by_id('TR') }

            before :each do
              # give corporation a route so that a train must be bought
              hex = game.hex_by_id(corporation.coordinates)
              tile = game.tile_by_id('6-0')
              hex.lay(tile.rotate!(2))

              game.stock_market.set_par(corporation3, game.stock_market.par_prices[0])
              corporation3.cash = 1000
              corporation3.ipoed = true

              next_round! # get past turn 1 so shares are sellable

              # skip past non train-buying actions
              until game.active_step.is_a?(Engine::Step::Train)
                action = Action::Pass.new(game.current_entity)
                game.process_action(action)
              end
            end

            it 'does not allow declaring bankruptcy when president has enough cash to buy a train' do
              train = remove_trains_until!('6')

              corporation.cash = train.price - 1
              corporation.player.cash = 1

              action = Action::Bankrupt.new(corporation)
              expect { subject.process_action(action) }.to raise_error GameError, /Cannot go bankrupt/
            end

            it 'does not allow declaring bankruptcy when president has enough sellable shares to buy a train' do
              # buy another share of corporation2 for some liquidity; other
              # player has same number of shares and corporation2s cannot be
              # dumped during 1889 EMR
              game.share_pool.buy_shares(corporation.player, corporation2.shares.first)

              # get to the right operating corporation
              game.round.next_entity! until game.current_entity == corporation

              # 6T, cost is $630
              remove_trains_until!('6')

              corporation.cash = 600
              corporation.player.cash = 29

              expect(game.liquidity(player, emergency: true)).to eq(119)

              action = Action::Bankrupt.new(corporation)
              expect { subject.process_action(action) }.to raise_error GameError, /Cannot go bankrupt/
            end

            it 'does allow declaring bankruptcy when president does not have enough liquidity to buy a train' do
              # buy another share of corporation2 for some liquidity; other
              # player has same number of shares and corporation2s cannot be
              # dumped during 1889 EMR
              game.share_pool.buy_shares(corporation.player, corporation2.shares.first)

              # get to the right operating corporation
              game.round.next_entity! until game.current_entity == corporation

              # 6T, cost is $630
              remove_trains_until!('6')

              corporation.cash = 530
              corporation.player.cash = 9

              expect(game.liquidity(player, emergency: true)).to eq(99)

              action = Action::Bankrupt.new(corporation)
              subject.process_action(action)
              expect(game.send(:bankruptcy_limit_reached?)).to be true
            end
          end
        end
      end

      describe 'blocking for Ehime Railway' do
        before :each do
          ehime.owner = game.players[1]
          game.phase.next!
        end

        it 'can lay a tile' do
          expect(subject.active_step).to be_a Engine::Step::BuyTrain

          expect(game.active_players).to eq([game.players[0]])

          subject.process_action(
            Action::BuyCompany.new(
              corporation,
              company: ehime,
              price: 40,
            )
          )

          expect(game.active_players).to eq([game.players[1]])
          expect(subject.active_step).to be_a Engine::Game::G1889::Step::SpecialTrack

          action = Action::LayTile.new(ehime, tile: game.tile_by_id('14-0'), hex: game.hex_by_id('C4'), rotation: 1)
          subject.process_action(action)

          expect(subject.active_step).to be_a Engine::Step::BuyTrain
          expect(game.active_players).to eq([game.players[0]])
          expect(subject.active_entities).to eq([corporation])
        end

        it 'requires a pass action if not laying' do
          expect(subject.active_step).to be_a Engine::Step::BuyTrain

          train = subject.active_step.buyable_trains(corporation).first

          expect(game.active_players).to eq([game.players[0]])

          subject.process_action(
            Action::BuyCompany.new(
              corporation,
              company: ehime,
              price: 40,
            )
          )

          expect(game.active_players).to eq([game.players[1]])
          expect(subject.active_step).to be_a Engine::Game::G1889::Step::SpecialTrack

          action = Action::BuyTrain.new(corporation, train: train, price: train.price)
          expect { subject.process_action(action) }.to raise_error(GameError)

          action = Action::Pass.new(ehime)
          subject.process_action(action)

          expect(subject.active_step).to be_a Engine::Step::BuyTrain
          expect(game.active_players).to eq([game.players[0]])
          expect(subject.active_entities).to eq([corporation])
        end
      end
    end

    context '#18chesapeake' do
      let(:game) { Game::G18Chesapeake::Game.new(players) }
      let(:corporation) { game.corporation_by_id('N&W') }
      let(:corporation2) { game.corporation_by_id('PRR') }
      subject { move_to_or! }

      before :each do
        game.stock_market.set_par(corporation, game.stock_market.par_prices[0])
        game.stock_market.set_par(corporation2, game.stock_market.par_prices[0])
        next_round!

        corporation.cash = 1000
        corporation.owner = player
        corporation2.cash = 1000
        corporation2.owner = player
        player.cash = 2000
        player2.cash = 2000
        # Make player 1 president of two companies, player 2 have the same amount of shares
        4.times { game.share_pool.buy_shares(player, corporation.shares.first) }
        5.times { game.share_pool.buy_shares(player2, corporation.shares.first) }
        3.times { game.share_pool.buy_shares(player, corporation2.shares.first) }
        4.times { game.share_pool.buy_shares(player2, corporation2.shares.first) }
        player.cash = 2000
        player2.cash = 2000
        subject.process_action(Action::LayTile.new(corporation, tile: Tile.for('57'), hex: hex_c13, rotation: 1))
      end

      describe 'sellable_bundles' do
        it 'should return bundles that cause a president change' do
          player.cash = 1
          corporation.cash = 1
          expect(subject.current_entity).to eq(corporation)
          bundles = game.sellable_bundles(player, corporation)
          # Player is president of corp 1, and it is the current corp
          expect(bundles.size).to eq(0)

          bundles = game.sellable_bundles(player, corporation2)
          # Player is president of corp 2, selling shares will cause a president change
          # Only one share can sell to raise the 80 yen needed for a 2 train
          expect(bundles.size).to eq(1)
        end
      end

      describe 'buyable_trains' do
        it 'returns other corp trains if no shares are sold' do
          train = subject.active_step.buyable_trains(corporation).first
          fake_buy_train(train, corporation2)
          corporation.cash = 1
          player.cash = 1

          available = subject.active_step.buyable_trains(corporation)
          expect(available.size).to eq(2)
        end
        it 'returns other corp trains if sold shares does not exceed face value' do
          train = subject.active_step.buyable_trains(corporation).first
          fake_buy_train(train, corporation2)
          corporation.cash = 1
          player.cash = 1

          bundle = game.bundles_for_corporation(player, corporation2).first
          subject.process_action(Action::SellShares.new(
            player,
            shares: bundle.shares,
            share_price: bundle.price_per_share,
            percent: bundle.percent,
          ))
          available = subject.active_step.buyable_trains(corporation)
          expect(available.size).to eq(2)
        end
        it 'returns only depot trains if sold shares exceeds face value' do
          train = subject.active_step.buyable_trains(corporation).first
          fake_buy_train(train, corporation2)
          while (train = subject.active_step.buyable_trains(corporation).first).name != '4'
            fake_buy_train(train, corporation2)
          end

          corporation.cash = 1
          player.cash = 1

          bundle = game.bundles_for_corporation(player, corporation2)[3]

          subject.process_action(Action::SellShares.new(
            player,
            shares: bundle.shares,
            share_price: bundle.price_per_share,
            percent: bundle.percent,
          ))
          available = subject.active_step.buyable_trains(corporation)
          expect(available.size).to eq(1)
        end
      end

      describe 'buy_train' do
        it 'does not allow EMR purchasing diesel when it can afford a 6' do
          # Allow diesels to be purchased
          while (train = subject.active_step.buyable_trains(corporation).first).name != '6'
            fake_buy_train(train, corporation2)
          end
          fake_buy_train(subject.active_step.buyable_trains(corporation).first, corporation2)

          corporation.cash = subject.active_step.buyable_trains(corporation).first.price
          train = subject.active_step.buyable_trains(corporation).find { |t| t.name == 'D' }
          action = Action::BuyTrain.new(corporation, train: train, price: train.price)
          fake_buy_train(train, corporation)
          expect { subject.process_action(action) }.to raise_error GameError
        end

        it 'allows purchasing another players train' do
          fake_buy_train(subject.active_step.buyable_trains(corporation).first, corporation2)

          corporation.cash = 1
          train = corporation2.trains.first
          player.cash = train.price
          action = Action::BuyTrain.new(corporation, train: train, price: train.price)

          subject.process_action(action)
        end
        it 'does not allow purchasing another players train for above price' do
          fake_buy_train(subject.active_step.buyable_trains(corporation).first, corporation2)

          corporation.cash = 1
          train = corporation2.trains.first
          player.cash = train.price
          action = Action::BuyTrain.new(corporation, train: train, price: train.price + 1)
          fake_buy_train(train, corporation)
          expect { subject.process_action(action) }.to raise_error GameError
        end
      end
    end

    describe '#available_hex' do
      context 'with awa' do
        let(:corporation) { game.corporation_by_id('AR') }

        it 'returns the layable hexes' do
          hexes = {
            hex_k8 => [1, 2, 3, 4],
          }
          hexes.each { |k, v| expect(subject.active_step.available_hex(corporation, k)).to eq(v) }

          subject.process_action(Action::LayTile.new(corporation, tile: Tile.for('5'), hex: hex_k8, rotation: 3))

          hexes = {
            hex_k6 => [0],
            hex_k8 => [1, 2, 3, 4],
            hex_l7 => [1],
          }
          subject = goto_new_or!
          hexes.each { |k, v| expect(subject.active_step.available_hex(corporation, k)).to eq(v) }

          subject.process_action(Action::LayTile.new(corporation, tile: Tile.for('9'), hex: hex_k6, rotation: 0))
          subject = goto_new_or!
          hexes = {
            hex_j3 => [5],
            hex_j5 => [4],
            hex_k6 => [0, 3],
            hex_k8 => [1, 2, 3, 4],
            hex_l7 => [1],
          }
          hexes.each { |k, v| expect(subject.active_step.available_hex(corporation, k)).to eq(v) }
        end
      end

      context 'with tse' do
        let(:corporation) { game.corporation_by_id('TR') }

        it 'can handle forks' do
          subject.process_action(Action::LayTile.new(corporation, tile: Tile.for('58'), hex: hex_g10, rotation: 0))
          goto_new_or!.process_action(Action::LayTile.new(corporation, tile: Tile.for('57'), hex: hex_g12, rotation: 0))

          game.phase.next!
          goto_new_or!.process_action(Action::LayTile.new(corporation, tile: Tile.for('15'), hex: hex_g12, rotation: 3))
          goto_new_or!.process_action(Action::LayTile.new(corporation, tile: Tile.for('9'), hex: hex_h13, rotation: 1))

          subject = goto_new_or!
          hexes = {
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
          }
          hexes.each { |k, v| expect(subject.active_step.available_hex(corporation, k)).to eq(v) }
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
          game.phase.next!
          subject.process_action(Action::LayTile.new(corporation, tile: Tile.for('440'), hex: hex_k4, rotation: 0))
        end
      end
    end

    context '1846' do
      let(:players) { %w[a b c d e] }
      let(:game) { Game::G1846::Game.new(players, optional_rules: [:first_ed]) }
      let(:corporation) { game.corporation_by_id('B&O') }
      let(:corporation_1) { game.corporation_by_id('PRR') }
      let(:big4) { game.minor_by_id('BIG4') }
      let(:ms) { game.minor_by_id('MS') }
      let(:hex_b8) { game.hex_by_id('B8') }
      let(:hex_d14) { game.hex_by_id('D14') }
      let(:hex_g19) { game.hex_by_id('G19') }

      subject { move_to_or! }

      before :each do
        game.stock_market.set_par(corporation, game.stock_market.par_prices[0])
        corporation.ipoed = true
        corporation.cash = 80
        bundle = ShareBundle.new(corporation.shares.first)
        game.share_pool.transfer_shares(bundle, game.players.first)

        game.stock_market.set_par(corporation_1, game.stock_market.par_prices[0])
        corporation_1.ipoed = true
        corporation_1.cash = 80
        bundle = ShareBundle.new(corporation_1.shares.first)
        game.share_pool.transfer_shares(bundle, game.players[1])

        ms.owner = game.players[1]
        big4.owner = game.players[2]
      end

      describe 'Steamboat Company' do
        let(:company) { game.company_by_id('SC') }
        before :each do
          company.owner = game.players.first

          allow(ms).to receive(:floated?) { true }
        end

        it 'handles full lifecycle of assigning to hexes and corporations' do
          expect(company).not_to be_assigned_to(corporation)
          expect(company).not_to be_assigned_to(corporation_1)
          expect(company).not_to be_assigned_to(hex_d14)
          expect(company).not_to be_assigned_to(hex_g19)

          subject.process_action(Action::Assign.new(company, target: hex_d14))
          expect(company).to be_assigned_to(hex_d14)
          expect(company).not_to be_assigned_to(hex_g19)

          action = Action::Assign.new(company, target: hex_g19)
          expect { subject.process_action(action) }.to raise_error GameError

          subject.process_action(Action::Assign.new(company, target: corporation))
          expect(company).to be_assigned_to(corporation)
          expect(company).not_to be_assigned_to(corporation_1)

          action = Action::Assign.new(company, target: corporation_1)
          expect { subject.process_action(action) }.to raise_error GameError

          subject = goto_new_or!

          subject.process_action(Action::Assign.new(company, target: ms))
          expect(company).not_to be_assigned_to(corporation)
          expect(company).not_to be_assigned_to(corporation_1)
          expect(company).to be_assigned_to(ms)

          subject = goto_new_or!

          subject.process_action(Action::Assign.new(company, target: hex_g19))
          expect(company).not_to be_assigned_to(hex_d14)
          expect(company).to be_assigned_to(hex_g19)

          subject.process_action(Action::Assign.new(company, target: corporation_1))
          expect(company).not_to be_assigned_to(corporation)
          expect(company).not_to be_assigned_to(ms)
          expect(company).to be_assigned_to(corporation_1)

          subject.process_action(
            Action::BuyCompany.new(
              corporation,
              company: company,
              price: 1,
            )
          )
          expect(company).to be_assigned_to(corporation)
          expect(company).to be_assigned_to(hex_g19)
          expect(company).not_to be_assigned_to(corporation_1)
          expect(company).not_to be_assigned_to(hex_d14)

          action = Action::Assign.new(company, target: corporation)
          expect { subject.process_action(action) }.to raise_error GameError

          action = Action::Assign.new(company, target: corporation_1)
          expect { subject.process_action(action) }.to raise_error GameError

          subject.process_action(Action::Assign.new(company, target: hex_d14))
          expect(company).to be_assigned_to(hex_d14)
          expect(company).not_to be_assigned_to(hex_g19)

          action = Action::Assign.new(company, target: hex_g19)
          expect { subject.process_action(action) }.to raise_error GameError

          subject = goto_new_or!

          expect(company).to be_assigned_to(corporation)
          expect(company).to be_assigned_to(hex_d14)
          expect(company).not_to be_assigned_to(corporation_1)
          expect(company).not_to be_assigned_to(hex_g19)

          action = Action::Assign.new(company, target: corporation_1)
          expect { subject.process_action(action) }.to raise_error GameError

          subject.process_action(Action::Assign.new(company, target: hex_g19))
          expect(company).to be_assigned_to(hex_g19)
        end
      end

      describe 'C&WI' do
        let(:company) { game.company_by_id('C&WI') }
        let(:tile) { game.hex_by_id('D6').tile }
        let(:city) { tile.cities[3] }
        let(:cities) { tile.cities }

        before :each do
          company.owner = game.players.first
        end

        describe 'reservation' do
          before :each do
            expect(city.reservations).to eq([company])
          end

          it 'is removed if owned by a player when a 5 train is bought' do
            goto_train_step!
            train = remove_trains_until!('5')
            corporation.cash = train.price

            subject.process_action(
              Action::BuyTrain.new(
                corporation,
                train: train,
                price: train.price,
              )
            )

            expect(city.reservations).to eq([])
          end

          it 'is removed when a corporation buys in the C&WI' do
            subject.process_action(
              Action::BuyCompany.new(
                corporation,
                company: company,
                price: 1,
              )
            )

            expect(city.reservations).to eq([])
          end
        end

        describe 'token placement' do
          before :each do
            subject.process_action(
              Action::BuyCompany.new(
                corporation,
                company: company,
                price: 1,
              )
            )
          end

          describe 'can place' do
            before :each do
              expect(city.tokens).to eq([nil])
            end

            it 'on the yellow Chi tile, city 3' do
              subject.process_action(Action::PlaceToken.new(company, city: city, slot: 0))
              expect(city.tokens.map(&:corporation)).to eq([corporation])
            end

            it 'on the green Chi tile, city 3' do
              expect(city.revenue.values.uniq).to eq([10])
              game.hex_by_id('D6').lay(game.tile_by_id('298-0'))
              city = game.hex_by_id('D6').tile.cities[3]
              expect(city.revenue.values.uniq).to eq([40])

              subject.process_action(Action::PlaceToken.new(company, city: city, slot: 0))
              expect(city.tokens.map(&:corporation)).to eq([corporation])
            end
          end

          describe 'cannot place' do
            before :each do
              expect(city.tokens).to eq([nil])
            end

            after :each do
              expect(city.tokens).to eq([nil])
            end

            (0..2).each do |other_city|
              it "on yellow Chi tile, city #{other_city}" do
                action = Action::PlaceToken.new(company, city: cities[other_city], slot: 0)
                expect { subject.process_action(action) }.to raise_error GameError, /can only place token on D6 city 3/
              end

              it "on green Chi tile, city #{other_city}" do
                expect(city.revenue.values.uniq).to eq([10])
                game.hex_by_id('D6').lay(game.tile_by_id('298-0'))
                city = game.hex_by_id('D6').tile.cities[other_city]
                expect(city.revenue.values.uniq).to eq([40])

                action = Action::PlaceToken.new(company, city: city, slot: 0)
                expect { subject.process_action(action) }.to raise_error GameError, /can only place token on D6 city 3/
              end
            end
          end
        end
      end

      describe 'issue_shares action' do
        let(:tile) { game.hex_by_id('G19').tile }
        let(:city) { tile.cities.first }

        before :each do
          corporation.cash = 0
        end

        it 'is an available until buy train step' do
          game.buy_train(corporation, game.trains.first, :free)
          city.place_token(corporation, corporation.tokens.first, free: true)
          next_round!

          expect(subject.actions_for(corporation)).to include('sell_shares')
          expect(game.issuable_shares(corporation).size).to eq(2)

          # Pass on tile lay and place token step
          subject.process_action(Action::Pass.new(corporation))

          expect(subject.actions_for(corporation)).to include('sell_shares')

          # Run route step
          action = Engine::Action::Base.action_from_h({
                                                        'type' => 'run_routes',
                                                        'entity' => 'B&O',
                                                        'entity_type' => 'corporation',
                                                        'routes' => [{
                                                          'train' => '2-0',
                                                          'connections' => [%w[H20 G19]],
                                                        }],
                                                      }, game)
          subject.process_action(action)

          expect(subject.actions_for(corporation)).to include('sell_shares')

          # Dividend step
          corporation.cash += 80
          subject.process_action(Action::Dividend.new(corporation, kind: 'payout'))

          expect(subject.actions_for(corporation)).not_to include('sell_shares')

          # Pass on buy train step
          subject.process_action(Action::Pass.new(corporation))

          expect(subject.actions_for(corporation)).not_to include('sell_shares')
        end

        it 'provides the correct amount of cash' do
          step = subject.step_for(corporation, 'sell_shares')
          expect(step.issuable_shares(corporation)[0].price).to eq(137)
          expect(step.issuable_shares(corporation)[1].price).to eq(274)

          action = Action::SellShares.new(corporation, shares: corporation.shares[1], share_price: 135, percent: 10)
          subject.process_action(action)

          expect(corporation.cash).to eq(135)
          expect(game.share_pool.num_shares_of(corporation)).to eq(1)
          expect(corporation.num_shares_of(corporation)).to eq(7)
        end

        it 'is no longer available after issuing' do
          action = Action::SellShares.new(corporation, shares: corporation.shares.first, share_price: 135, percent: 10)
          subject.process_action(action)

          expect(subject.actions_for(corporation)).not_to include('sell_shares')
        end

        it 'causes the track and token step to block when cash is 0' do
          expect(subject.actions_for(corporation)).to include('lay_tile')
          expect(subject.actions_for(corporation)).to include('place_token')
        end

        it 'is not available if no shares to issue' do
          bundle = ShareBundle.new(corporation.shares.first(4))
          game.share_pool.transfer_shares(bundle, game.players[0])

          bundle = ShareBundle.new(corporation.shares)
          game.share_pool.transfer_shares(bundle, game.players[1])

          expect(subject.actions_for(corporation)).not_to include('sell_shares')
        end

        it 'is not available if no additional shares can be in the bank pool' do
          bundle = ShareBundle.new(corporation.shares.first(2))
          game.share_pool.transfer_shares(bundle, game.share_pool)

          expect(subject.actions_for(corporation)).not_to include('sell_shares')
        end
      end

      describe 'redeem_shares action' do
        let(:tile) { game.hex_by_id('G19').tile }
        let(:city) { tile.cities.first }

        before :each do
          corporation.cash = 330
          bundle = ShareBundle.new(corporation.shares.first(2))
          game.share_pool.transfer_shares(bundle, game.share_pool)
        end

        it 'is an available until buy train step' do
          game.buy_train(corporation, game.trains.first, :free)
          city.place_token(corporation, corporation.tokens.first, free: true)
          next_round!

          expect(subject.actions_for(corporation)).to include('buy_shares')
          expect(game.redeemable_shares(corporation).size).to eq(2)

          # Pass on tile lay and place token step
          subject.process_action(Action::Pass.new(corporation))

          expect(subject.actions_for(corporation)).to include('buy_shares')

          # Run route sstep
          action = Engine::Action::Base.action_from_h({
                                                        'type' => 'run_routes',
                                                        'entity' => 'B&O',
                                                        'entity_type' => 'corporation',
                                                        'routes' => [{
                                                          'train' => '2-0',
                                                          'connections' => [%w[H20 G19]],
                                                        }],
                                                      }, game)
          subject.process_action(action)

          expect(subject.actions_for(corporation)).to include('buy_shares')

          # Dividend step
          subject.process_action(Action::Dividend.new(corporation, kind: 'payout'))

          corporation.cash += 80
          expect(subject.actions_for(corporation)).not_to include('buy_shares')

          # Pass on buy train step
          subject.process_action(Action::Pass.new(corporation))

          expect(subject.actions_for(corporation)).not_to include('buy_shares')
        end

        it 'costs the correct amount of cash' do
          step = subject.step_for(corporation, 'buy_shares')
          expect(step.redeemable_shares(corporation).map(&:price)).to include(165, 330)

          action = Action::BuyShares.new(corporation,
                                         shares: game.share_pool.shares_of(corporation).first,
                                         share_price: 165,
                                         percent: 10)
          subject.process_action(action)

          expect(corporation.cash).to eq(165)
          expect(game.share_pool.num_shares_of(corporation)).to eq(1)
          expect(corporation.num_shares_of(corporation)).to eq(7)
        end

        it 'is no longer available after redeeming' do
          action = Action::BuyShares.new(corporation,
                                         shares: game.share_pool.shares_of(corporation).first,
                                         share_price: 165,
                                         percent: 10)
          subject.process_action(action)

          expect(subject.actions_for(corporation)).not_to include('buy_shares')
        end

        it 'is not available if no shares to redeem' do
          bundle = ShareBundle.new(game.share_pool.shares_of(corporation))
          game.share_pool.transfer_shares(bundle, corporation)

          expect(subject.actions_for(corporation)).not_to include('buy_shares')
          expect(game.redeemable_shares(corporation).size).to eq(0)
        end
      end

      describe 'buy_train' do
        before :each do
          goto_train_step!

          # Allow 7/8 to be purchased
          while (train = subject.active_step.buyable_trains(corporation).first).name != '6'
            fake_buy_train(train, corporation_1)
          end
          fake_buy_train(subject.active_step.buyable_trains(corporation).first, corporation_1)

          # enough cash for a 6
          corporation.cash = subject.active_step.buyable_trains(corporation).first.price
        end

        describe 'corporation can afford a 6' do
          before :each do
            corporation.cash = 800
          end

          it 'does not allow president contributing cash to purchase a 7/8' do
            # only buyable variant is 6
            train = subject.active_step
                      .buyable_trains(corporation)
                      .find(&:from_depot?)
            expect(subject.active_step.buyable_train_variants(train, corporation)).to eq([train.variants['6']])

            expect(corporation.cash).to eq(800)
            expect(corporation.trains).to be_empty

            # buying it raises error
            expect { real_buy_depot_train(corporation, '7/8') }.to raise_error GameError, 'Not a buyable train'
          end

          it 'does allow the corporation to emergency issue shares to purchase a 7/8' do
            bundle = game.emergency_issuable_bundles(corporation).first

            subject.process_action(Action::SellShares.new(
                                     corporation,
                                     shares: bundle.shares,
                                     share_price: bundle.price_per_share,
                                     percent: bundle.percent,
                                   ))

            expect(corporation.cash).to eq(912)

            buyable_depot_trains = subject.active_step.buyable_trains(corporation).select(&:from_depot?)
            expect(buyable_depot_trains.size).to eq(1)

            real_buy_depot_train(corporation, '7/8')

            expect(corporation.cash).to eq(12)
            expect(corporation.trains.map(&:name)).to eq(%w[7/8])
          end
        end

        describe 'corporation cannot afford a 6' do
          before :each do
            corporation.cash = 799
          end

          describe 'has shares to issue' do
            describe 'with stock price of 112' do
              before :each do
                game.stock_market.set_par(corporation, game.stock_market.par_prices[3])
              end

              it 'can issue one share to buy a 6 and not a 7/8' do
                bundle = game.emergency_issuable_bundles(corporation).first

                subject.process_action(Action::SellShares.new(
                                         corporation,
                                         shares: bundle.shares,
                                         share_price: bundle.price_per_share,
                                         percent: bundle.percent,
                                       ))
                expect { real_buy_depot_train(corporation, '7/8') }.to raise_error GameError, 'Not a buyable train'

                real_buy_depot_train(corporation, '6')
                expect(corporation.trains.map(&:name)).to eq(%w[6])
              end

              it 'can issue two shares to buy a 7/8 and not a 6' do
                bundles = game.emergency_issuable_bundles(corporation)
                bundle = bundles[1]

                subject.process_action(Action::SellShares.new(
                                         corporation,
                                         shares: bundle.shares,
                                         share_price: bundle.price_per_share,
                                         percent: bundle.percent,
                                       ))
                expect { real_buy_depot_train(corporation, '6') }.to raise_error GameError, 'Not a buyable train'
                real_buy_depot_train(corporation, '7/8')
                expect(corporation.trains.map(&:name)).to eq(%w[7/8])
              end
            end

            it 'does not allow president contributing cash to purchase a 7/8' do
              expect { real_buy_depot_train(corporation, '7/8') }.to raise_error GameError, 'Not a buyable train'
            end
          end

          describe 'no shares to issue' do
            before :each do
              # add shares to the pool so the corp may not issue any
              bundle = ShareBundle.new(corporation.shares.slice(0..2))
              game.share_pool.transfer_shares(bundle, game.share_pool)
              expect(game.emergency_issuable_bundles(corporation)).to be_empty
            end

            it 'allows president contributing cash to purchase a 7/8' do
              initial_president_cash = corporation.owner.cash

              expect(corporation.cash).to eq(799)
              expect(corporation.trains).to be_empty

              real_buy_depot_train(corporation, '7/8')

              expect(corporation.cash).to eq(0)
              expect(corporation.trains.map(&:name)).to eq(%w[7/8])
              expect(corporation.owner.cash).to eq(initial_president_cash - 101)
            end

            it 'allows president selling shares to purchase a 7/8 even if a 6 is affordable '\
               'with the presidential cash' do
              player = corporation.owner
              player.cash = 1

              # give the president a 3rd share that they can sell
              bundle = ShareBundle.new(corporation.shares[0])
              game.share_pool.transfer_shares(bundle, player)

              bundle = game.bundles_for_corporation(player, corporation).first
              subject.process_action(Action::SellShares.new(
                                       player,
                                       shares: bundle.shares,
                                       share_price: bundle.price_per_share,
                                       percent: bundle.percent,
                                     ))

              expect(player.cash).to eq(138)
              expect(corporation.cash).to eq(799)

              buyable_depot_trains = subject.active_step.buyable_trains(corporation).select(&:from_depot?)
              expect(buyable_depot_trains.size).to eq(1)

              real_buy_depot_train(corporation, '7/8')

              expect(player.cash).to eq(37)
              expect(corporation.cash).to eq(0)
              expect(corporation.trains.map(&:name)).to eq(%w[7/8])
            end
          end
        end
      end
    end
  end
end
