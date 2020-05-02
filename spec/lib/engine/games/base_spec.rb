# frozen_string_literal: true

require './spec/spec_helper'
require 'engine/game/g_1889'
require 'engine/action/pass'
require 'engine/action/message'

module Engine
  describe Game::Base do
    let(:players) { [Player.new('a'), Player.new('b')] }
    # Use G1889 to define other constants needed
    subject { Game::G1889.new(players) }

    describe '#process_action?' do
      it 'should add an action' do
        subject.process_action(Engine::Action::Pass.new(subject.current_entity))
        expect(subject.actions.size).to be 1
      end
    end

    describe '#rollback' do
      it 'should remove last action' do
        subject.process_action(Engine::Action::Message.new(subject.current_entity, 'testing'))
        subject.process_action(Engine::Action::Pass.new(subject.current_entity))
        newsubject = subject.rollback
        expect(newsubject.actions.size).to be 1
        expect(newsubject.actions.last).to be_a Engine::Action::Message
      end

      it 'should remove last action leaving messages' do
        subject.process_action(Engine::Action::Pass.new(subject.current_entity))
        subject.process_action(Engine::Action::Message.new(subject.current_entity, 'testing'))
        newsubject = subject.rollback
        expect(newsubject.actions.size).to be 1
        expect(newsubject.actions.last).to be_a Engine::Action::Message
      end

      it 'should remove last action leaving multiple messages' do
        subject.process_action(Engine::Action::Pass.new(subject.current_entity))
        subject.process_action(Engine::Action::Pass.new(subject.current_entity))
        subject.process_action(Engine::Action::Message.new(subject.current_entity, 'testing1'))
        subject.process_action(Engine::Action::Message.new(subject.current_entity, 'testing2'))
        newsubject = subject.rollback
        expect(newsubject.actions.size).to be 3
        expect(newsubject.actions[0]).to be_a Engine::Action::Pass
        expect(newsubject.actions[1].message).to be 'testing1'
        expect(newsubject.actions[2].message).to be 'testing2'
      end
    end
  end
end
