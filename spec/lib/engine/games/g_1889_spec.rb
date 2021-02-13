# frozen_string_literal: true

require './spec/spec_helper'

require 'engine/game/g_1889'
require 'engine/part/city'
require 'json'

module Engine
  describe Game::G1889 do
    let(:players) { %w[a b] }

    let(:actions) do
      [
        { 'type' => 'pass', 'entity' => 'a', 'entity_type' => 'player', 'id' => 1 },
        { 'type' => 'message', 'entity' => 'a', 'entity_type' => 'player', 'message' => 'testing', 'id' => 2 },
        { 'type' => 'pass', 'entity' => 'b', 'entity_type' => 'player', 'id' => 3 },
        { 'type' => 'undo', 'entity' => 'a', 'entity_type' => 'player', 'id' => 4 },
      ]
    end

    context 'on init with actions' do
      let(:players) { %w[a b c] }
      subject(:subject_with_actions) { Game::G1889.new(players, actions: actions) }
      it 'should process constructor actions' do
        expect(subject_with_actions.raw_actions.size).to be 4
        expect(subject_with_actions.current_entity.name).to be players[1]
      end

      it 'should process extra actions' do
        action = Engine::Action::Pass.new(subject_with_actions.current_entity)
        subject_with_actions.process_action(action)
        expect(subject_with_actions.raw_actions.size).to be 5
        expect(subject_with_actions.current_entity.name).to be players[2]
        expect(subject_with_actions.redo_possible).to be false
      end

      it 'should return a new game when processing a undo' do
        action = Engine::Action::Undo.new(subject_with_actions.current_entity)
        game2 = subject_with_actions.process_action(action)
        expect(subject_with_actions.undo_possible).to be true
        expect(subject_with_actions.redo_possible).to be true
        expect(subject_with_actions).not_to eq(game2)
        expect(game2.raw_actions.size).to be 5
        expect(game2.current_entity.name).to be players[0]
        expect(game2.redo_possible).to be true
        # As only messages are left, we can no longer undo
        expect(game2.undo_possible).to be false
      end

      it 'should allow redo if a user sends a message' do
        action = Engine::Action::Message.new(subject_with_actions.current_entity, message: 'testing more')
        expect(subject_with_actions.redo_possible).to be true
        subject_with_actions.process_action(action)
        expect(subject_with_actions.raw_actions.size).to be 5
        expect(subject_with_actions.redo_possible).to be true
      end

      it 'should return a new game when processing a redo' do
        action = Engine::Action::Redo.new(subject_with_actions.current_entity)
        expect(subject_with_actions.redo_possible).to be true
        game2 = subject_with_actions.process_action(action)
        expect(subject_with_actions).not_to eq(game2)
        expect(game2.raw_actions.size).to be 5
        expect(game2.current_entity.name).to be players[2]
        expect(game2.redo_possible).to be false
      end

      it 'should return a new game when processing each undo/redo and the correct player should be active' do
        action = Engine::Action::Undo.new(subject_with_actions.current_entity)
        game2 = subject_with_actions.process_action(action)
        expect(subject_with_actions).not_to eq(game2)
        expect(game2.raw_actions.size).to be 5
        expect(game2.current_entity.name).to be players[0]
        action = Engine::Action::Redo.new(game2.current_entity)
        game3 = game2.process_action(action)
        expect(game2).not_to eq(game3)
        expect(game3.raw_actions.size).to be 6
        expect(game3.current_entity.name).to be players[1]
        action = Engine::Action::Undo.new(game3.current_entity)
        game4 = game3.process_action(action)
        expect(game3).not_to eq(game4)
        expect(game4.raw_actions.size).to be 7
        expect(game4.current_entity.name).to be players[0]
      end

      it 'should allow undo after game end' do
        action = Engine::Action::EndGame.new(subject_with_actions.current_entity)
        subject_with_actions.process_action(action)
        expect(subject_with_actions.raw_actions.size).to be 5
        expect(subject_with_actions.finished).to be true
        action = Engine::Action::Undo.new(subject_with_actions.current_entity)
        game2 = subject_with_actions.process_action(action)
        expect(game2).not_to eq(subject_with_actions)
        expect(game2.raw_actions.size).to be 6
        expect(game2.finished).to be false
      end

      it 'should allow messages after game end' do
        action = Engine::Action::EndGame.new(subject_with_actions.current_entity)
        subject_with_actions.process_action(action)
        expect(subject_with_actions.raw_actions.size).to be 5
        expect(subject_with_actions.finished).to be true
        action = Engine::Action::Message.new(subject_with_actions.current_entity, message: 'hi')
        subject_with_actions.process_action(action)
        expect(subject_with_actions.raw_actions.size).to be 6
        expect(subject_with_actions.finished).to be true
      end
    end

    subject { Game::G1889.new(players) }

    context 'on init' do
      it 'starts with correct cash' do
        expect(subject.bank.cash).to eq(6160)
        expect(subject.players.map(&:cash)).to eq([420, 420])
      end

      it 'starts with an auction' do
        expect(subject.round).to be_a(Round::Auction)
      end

      it 'starts with player a' do
        expect(subject.round.entities).to eq(subject.players)
        expect(subject.round.current_entity).to eq(subject.players.first)
        expect(subject.current_entity).to eq(subject.players.first)
      end
    end
  end
end
