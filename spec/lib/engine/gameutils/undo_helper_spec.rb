# frozen_string_literal: true

require './spec/spec_helper'
require 'engine/gameutils/undo_helper'

module Engine
  describe GameUtils::UndoHelper do
    let(:initial_actions) do
      [
        { 'type' => 'pass', 'entity' => 'a', 'entity_type' => 'player' },
        { 'type' => 'message', 'entity' => 'a', 'entity_type' => 'player', 'message' => 'testing' },
        { 'type' => 'pass', 'entity' => 'b', 'entity_type' => 'player' },
        { 'type' => 'undo', 'entity' => 'a', 'entity_type' => 'player', 'steps' => 1 }
      ]
    end
    subject { GameUtils::UndoHelper.new }

    context 'on init' do
      it 'should process constructor actions' do
        expect(subject.undo_list).to eq([])
      end
    end
    describe '#process_action?' do
      it 'should process undo single steps' do
        subject.process_actions(initial_actions)
        expect(subject.undo_list).to eq([3])
      end

      it 'should process undo multiple steps and ignore keep on undo actions', skip: true do
        initial_actions.last['steps'] = 2
        subject.process_actions(initial_actions)
        expect(subject.undo_list).to eq([3, 1])
      end

      it 'should process undo and redos' do
        initial_actions << { 'type' => 'redo', 'entity' => 'a', 'entity_type' => 'player', 'steps' => 1 }
        subject.process_actions(initial_actions)
        expect(subject.undo_list).to eq([])
      end

      it 'should process objects as well as hashes' do
        initial_actions << Engine::Action::Redo.new(nil, 1)
        subject.process_actions(initial_actions)
        expect(subject.undo_list).to eq([])
      end
    end
    describe '#ignore_action?' do
      it 'should return true for Undo objects' do
        action = Engine::Action::Undo.new(nil, 1)
        expect(subject.ignore_action?(action)).to be true
      end

      it 'should return true for Redo objects' do
        action = Engine::Action::Redo.new(nil, 1)
        expect(subject.ignore_action?(action)).to be true
      end

      it 'should return false for objects with action.id not in undo list' do
        subject.process_actions(initial_actions)
        action = Engine::Action::Pass.new(nil)
        action.id = 0
        expect(subject.ignore_action?(action)).to be false
      end

      it 'should return true for objects with action.id in undo list' do
        subject.process_actions(initial_actions)
        action = Engine::Action::Pass.new(nil)
        action.id = 3
        expect(subject.ignore_action?(action)).to be true
      end
    end
  end
end
