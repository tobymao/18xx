# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G18RoyalGorge::Game do
  describe 'endgame_triggered_on_buy' do
    it 'endgame has not been triggered before last train rank is bought' do
      game = fixture_at_action(430)

      expect(game.turn_round_num).to eq([4, 2])
      expect(game.round.operating?).to eq(true)
      expect(game.round.stock?).to eq(false)
      expect(game.game_ending_description).to eq(nil)
    end

    it 'game will end after next complete set of ORs after last train rank is bought' do
      game = fixture_at_action(431)

      expect(game.turn_round_num).to eq([4, 2])
      expect(game.round.operating?).to eq(true)
      expect(game.round.stock?).to eq(false)
      expect(game.game_ending_description).to eq('6x2-train was bought/exported : Game Ends at conclusion of OR 5.2')
    end

    it 'game will end after next complete set of ORs after last train rank is bought and in next SR' do
      game = fixture_at_action(445)

      expect(game.turn_round_num).to eq([5, 1])
      expect(game.round.operating?).to eq(false)
      expect(game.round.stock?).to eq(true)
      expect(game.game_ending_description).to eq('6x2-train was bought/exported : Game Ends at conclusion of OR 5.2')
    end

    it 'game will end after next complete set of ORs after last train rank is bought and in next OR' do
      game = fixture_at_action(452)

      expect(game.turn_round_num).to eq([5, 1])
      expect(game.round.operating?).to eq(true)
      expect(game.round.stock?).to eq(false)
      expect(game.game_ending_description).to eq('6x2-train was bought/exported : Game Ends at conclusion of OR 5.2')
    end

    it 'game over' do
      game = fixture_at_action(495)

      expect(game.turn_round_num).to eq([5, 2])
      expect(game.round.operating?).to eq(true)
      expect(game.round.stock?).to eq(false)
      expect(game.finished).to eq(true)
    end
  end

  describe 'endgame_triggered_on_export' do
    it 'endgame has not been triggered before last train rank is exported' do
      game = fixture_at_action(544)

      expect(game.turn_round_num).to eq([5, 2])
      expect(game.round.operating?).to eq(true)
      expect(game.round.stock?).to eq(false)
      expect(game.game_ending_description).to eq(nil)
    end

    it 'game will end after next complete set of ORs after last train rank is exported' do
      game = fixture_at_action(545)

      expect(game.turn_round_num).to eq([6, 1])
      expect(game.round.operating?).to eq(false)
      expect(game.round.stock?).to eq(true)
      expect(game.game_ending_description).to eq('6x2-train was bought/exported : Game Ends at conclusion of OR 6.2')
    end

    it 'game will end after next complete set of ORs after last train rank is exported and in next OR' do
      game = fixture_at_action(549)

      expect(game.turn_round_num).to eq([6, 1])
      expect(game.round.operating?).to eq(true)
      expect(game.round.stock?).to eq(false)
      expect(game.game_ending_description).to eq('6x2-train was bought/exported : Game Ends at conclusion of OR 6.2')
    end

    it 'will end on next action' do
      game = fixture_at_action(588)

      expect(game.turn_round_num).to eq([6, 2])
      expect(game.round.operating?).to eq(true)
      expect(game.round.stock?).to eq(false)
      expect(game.game_ending_description).to eq('6x2-train was bought/exported : Game Ends at conclusion of OR 6.2')
    end

    it 'game over' do
      game = fixture_at_action(589)

      expect(game.finished).to eq(true)
    end
  end

  describe 'endgame_shorter_triggered_on_buy' do
    it 'endgame has not been triggered before last train rank is bought' do
      game = fixture_at_action(430)

      expect(game.turn_round_num).to eq([4, 2])
      expect(game.round.operating?).to eq(true)
      expect(game.round.stock?).to eq(false)
      expect(game.game_ending_description).to eq(nil)
    end

    it 'game will end after next complete set of ORs after last train rank is bought' do
      game = fixture_at_action(431)

      expect(game.turn_round_num).to eq([4, 2])
      expect(game.round.operating?).to eq(true)
      expect(game.round.stock?).to eq(false)
      expect(game.game_ending_description).to eq('6x2-train was bought/exported : Game Ends at conclusion of OR 4.2')
    end

    it 'game over' do
      game = fixture_at_action(445)

      expect(game.turn_round_num).to eq([4, 2])
      expect(game.round.operating?).to eq(true)
      expect(game.round.stock?).to eq(false)
      expect(game.finished).to eq(true)
    end
  end

  describe 'endgame_shorter_triggered_on_export' do
    it 'endgame has not been triggered before last train rank is exported' do
      game = fixture_at_action(544)

      expect(game.turn_round_num).to eq([5, 2])
      expect(game.round.operating?).to eq(true)
      expect(game.round.stock?).to eq(false)
      expect(game.game_ending_description).to eq(nil)
    end

    it 'game will end after next complete set of ORs after last train rank is exported' do
      game = fixture_at_action(545)

      expect(game.turn_round_num).to eq([6, 1])
      expect(game.round.operating?).to eq(false)
      expect(game.round.stock?).to eq(true)
      expect(game.game_ending_description).to eq('6x2-train was bought/exported : Game Ends at conclusion of OR 6.2')
    end

    it 'game will end after next complete set of ORs after last train rank is exported and in next OR' do
      game = fixture_at_action(549)

      expect(game.turn_round_num).to eq([6, 1])
      expect(game.round.operating?).to eq(true)
      expect(game.round.stock?).to eq(false)
      expect(game.game_ending_description).to eq('6x2-train was bought/exported : Game Ends at conclusion of OR 6.2')
    end

    it 'game over' do
      game = fixture_at_action(589)

      expect(game.turn_round_num).to eq([6, 2])
      expect(game.round.operating?).to eq(true)
      expect(game.round.stock?).to eq(false)
      expect(game.finished).to eq(true)
    end
  end
end
