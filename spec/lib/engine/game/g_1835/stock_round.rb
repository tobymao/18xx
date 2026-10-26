# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1835::Game do
  let(:game) { Engine::Game::G1835::Game.new(players) }
  let(:by) { game.corporation_by_id('BY') }
  let(:player_1) { game.players.find { |player| player.id == 'a' } }
  let(:player_2) { game.players.find { |player| player.id == 'b' } }
  let(:player_3) { game.players.find { |player| player.id == 'c' } }
  let(:player_4) { game.players.find { |player| player.id == 'd' } }

  describe 'should not let sales keep the stock round going' do
    let(:players) { %w[a b c d] }
    let(:game) { Engine::Game::G1835::Game.new(players) }

    def sell_starting_package
      buy(player_1, 'NF')
      buy(player_2, 'LD')
      buy(player_3, '1')
      buy(player_4, '2')
      buy(player_1, '3')
      buy(player_2, 'BY_D')
      buy(player_3, 'BB')
      buy(player_4, '4')
      buy(player_1, 'HB')
      buy(player_2, '5')
      buy(player_3, 'PB')
      buy(player_4, 'OBB')
      buy(player_1, '6')
    end

    def skip_minor_actions_in_or
      12.times do
        pass(game.active_step.current_entity)
      end
    end

    def no_action_but_mandatory_train_buy(corp)
      # skip laying track
      pass(corp)
      # buy mandatory train
      train = game.depot.depot_trains.first
      game.process_action(Engine::Action::BuyTrain.new(corp, train: train, price: train.price))
      pass(corp) # skip buying more trains
    end

    it 'no last buyer' do
      # sell the starting package
      sell_starting_package

      # player 3 could buy something in the following SR, but doesn't
      pass(player_3)
      skip_minor_actions_in_or

      no_action_but_mandatory_train_buy(by)

      sell_shares(player_3, 'BY')
      pass(player_3)
      pass(player_4)
      pass(player_1)
      # player 2 does not have any valid actions and is skipped

      # no action moving the PD was performed, so it must still be with player 3
      expect(game.players.first).to eq(player_3)
      # We should now be in an OR again
      expect(game.active_step.current_entity).to eq(game.minor_by_id('1'))
    end

    it 'last buyer passes' do
      # sell the starting package
      sell_starting_package

      # player 3 could buy something in the following SR, but doesn't
      pass(player_3)

      skip_minor_actions_in_or
      no_action_but_mandatory_train_buy(by)

      buy_shares(player_3, 'BY') # Last buy, PD goes to player 4
      pass(player_3)
      sell_shares(player_4, 'BY')
      pass(player_4)
      pass(player_1)
      pass(player_2)
      pass(player_3)

      # Player 3 bought last, rounded ended on them passing, PD must be with player 4
      expect(game.players.first).to eq(player_4)

      # We should now be in an OR again
      expect(game.active_step.current_entity).to eq(game.minor_by_id('1'))
    end

    it 'last buyer is skipped' do
      # sell the starting package
      sell_starting_package

      # player 3 could buy something in the following SR, but doesn't
      pass(player_3)

      skip_minor_actions_in_or
      no_action_but_mandatory_train_buy(by)

      buy_shares(player_3, 'BY') # Last buy, PD goes to player 4
      pass(player_3)
      pass(player_4)
      pass(player_1)
      sell_shares(player_2, 'BY')
      pass(player_2)
      # player 3 does not have any valid actions (BY not dumpable anymore) and is skipped

      # Player 3 bought last, rounded ended on them passing, PD must be with player 4
      expect(game.players.first).to eq(player_4)

      # We should now be in an OR again
      expect(game.active_step.current_entity).to eq(game.minor_by_id('1'))
    end

    it 'last buyer is not the first buyer' do
      # sell the starting package
      sell_starting_package

      # player 3 could buy something in the following SR, but doesn't
      pass(player_3)

      skip_minor_actions_in_or
      no_action_but_mandatory_train_buy(by)

      buy_shares(player_3, 'BY')
      pass(player_3)

      sell_shares(player_4, 'BY')
      buy_shares(player_4, 'SX')
      pass(player_4)
      sell_shares(player_1, 'BY')
      buy_shares(player_1, 'SX') # Last buy, PD goes to player 2
      pass(player_1)
      sell_shares(player_2, 'BY')
      pass(player_2)
      # player 3 is skipped
      pass(player_4)
      pass(player_1)

      # Player 3 bought last, rounded ended on them passing, PD must be with player 4
      expect(game.players.first).to eq(player_2)

      # We should now be in an OR again
      expect(game.active_step.current_entity).to eq(game.minor_by_id('1'))
    end
  end
end
