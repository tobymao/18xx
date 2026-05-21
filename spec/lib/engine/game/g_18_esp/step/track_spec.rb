# frozen_string_literal: true

require 'spec_helper'

# fixture_at_action derives the game title from the outermost describe class (.title),
# so this spec must be rooted at the Game class rather than the Step class.
describe Engine::Game::G18ESP::Game do
  describe '18ESP_game_end_second_eight' do
    # at_action 106: SFVA floated, not yet destination_connected — same anchor as CDC spec.
    let(:game) { fixture_at_action(106) }
    let(:step) { game.round.steps.find { |s| s.is_a?(Engine::Game::G18ESP::Step::Track) } }
    let(:sfva) { game.corporation_by_id('SFVA') }

    before { allow(game).to receive(:replaying?).and_return(false) }

    describe 'Track#auto_actions' do
      context 'when replaying? is true' do
        before { allow(game).to receive(:replaying?).and_return(true) }

        it 'returns [] regardless of destination state — covers both loading and strict mode' do
          step.instance_variable_set(:@acted, true)
          allow(sfva).to receive(:destination_connected?).and_return(false)
          expect(step.auto_actions(sfva)).to eq([])
        end
      end

      context 'when strict-mode replay (via @strict, not @loading)' do
        # replaying? is NOT stubbed here — the real method (@loading || @strict) must fire.
        before { allow(game).to receive(:replaying?).and_call_original }

        it 'returns [] when strict mode triggers replaying? via @strict instead of @loading' do
          game.instance_variable_set(:@loading, false)
          game.instance_variable_set(:@strict, true)
          step.instance_variable_set(:@acted, true)
          allow(sfva).to receive(:destination_connected?).and_return(false)
          allow(game).to receive(:check_for_destination_connection).with(sfva).and_return(true)
          expect(step.auto_actions(sfva)).to eq([])
        end
      end

      context 'when entity is already destination_connected?' do
        before do
          step.instance_variable_set(:@acted, true)
          allow(sfva).to receive(:destination_connected?).and_return(true)
        end

        it 'returns []' do
          expect(step.auto_actions(sfva)).to eq([])
        end
      end

      context 'when entity is not yet destination_connected and no new connection' do
        before do
          step.instance_variable_set(:@acted, true)
          allow(sfva).to receive(:destination_connected?).and_return(false)
          allow(game).to receive(:check_for_destination_connection).with(sfva).and_return(false)
        end

        it 'returns [] (no emission when nothing new)' do
          expect(step.auto_actions(sfva)).to eq([])
        end
      end

      context 'when entity becomes newly destination_connected' do
        before do
          step.instance_variable_set(:@acted, true)
          allow(sfva).to receive(:destination_connected?).and_return(false)
          allow(game).to receive(:check_for_destination_connection).with(sfva).and_return(true)
        end

        it 'emits DestinationConnection with the entity' do
          action = step.auto_actions(sfva).first
          expect(action).to be_a(Engine::Action::DestinationConnection)
          expect(action.corporations).to eq([sfva])
        end
      end
    end

    describe 'Track#actions' do
      before do
        allow(game.round).to receive(:current_entity).and_return(sfva)
        step.instance_variable_set(:@acted, true)
      end

      context 'when replaying? is true' do
        before { allow(game).to receive(:replaying?).and_return(true) }

        it 'does not include destination_connection — covers both loading and strict mode' do
          allow(sfva).to receive(:destination_connected?).and_return(false)
          expect(step.actions(sfva)).not_to include('destination_connection')
        end
      end

      context 'when strict-mode replay (via @strict, not @loading)' do
        # replaying? is NOT stubbed here — the real method (@loading || @strict) must fire.
        before { allow(game).to receive(:replaying?).and_call_original }

        it 'does not include destination_connection when strict mode triggers replaying? via @strict' do
          game.instance_variable_set(:@loading, false)
          game.instance_variable_set(:@strict, true)
          allow(sfva).to receive(:destination_connected?).and_return(false)
          allow(game).to receive(:check_for_destination_connection).with(sfva).and_return(true)
          expect(step.actions(sfva)).not_to include('destination_connection')
        end
      end

      context 'when entity is already destination_connected?' do
        before { allow(sfva).to receive(:destination_connected?).and_return(true) }

        it 'does not include destination_connection' do
          expect(step.actions(sfva)).not_to include('destination_connection')
        end
      end

      context 'when entity is not yet destination_connected?' do
        before { allow(sfva).to receive(:destination_connected?).and_return(false) }

        it 'includes destination_connection when newly connected' do
          allow(game).to receive(:check_for_destination_connection).with(sfva).and_return(true)
          expect(step.actions(sfva)).to include('destination_connection')
        end

        it 'does not include destination_connection when no new connection' do
          allow(game).to receive(:check_for_destination_connection).with(sfva).and_return(false)
          expect(step.actions(sfva)).not_to include('destination_connection')
        end
      end
    end

    describe 'Track#process_destination_connection' do
      it 'calls goal_reached!(:destination) on corporations.first' do
        action = Engine::Action::DestinationConnection.new(sfva, corporations: [sfva])
        expect(sfva).to receive(:goal_reached!).with(:destination)
        step.process_destination_connection(action)
      end

      it 'processes only corporations.first — single-entity invariant' do
        other = game.corporations.find { |c| c != sfva }
        action = Engine::Action::DestinationConnection.new(sfva, corporations: [sfva, other])
        expect(sfva).to receive(:goal_reached!).with(:destination)
        expect(other).not_to receive(:goal_reached!)
        step.process_destination_connection(action)
      end
    end
  end
end
