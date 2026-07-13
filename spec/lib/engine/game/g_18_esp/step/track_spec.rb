# frozen_string_literal: true

require 'spec_helper'

# fixture_at_action derives the game title from the outermost describe class (.title),
# so this spec must be rooted at the Game class rather than the Step class.
describe Engine::Game::G18ESP::Game do
  describe '18ESP_game_end_second_eight' do
    # at_action 96: SFVA operating (place_token done), not yet destination_connected — same anchor as CDC spec.
    let(:game) { fixture_at_action(96) }
    let(:step) { game.round.steps.find { |s| s.is_a?(Engine::Game::G18ESP::Step::Track) } }
    let(:sfva) { game.corporation_by_id('SFVA') }

    before { allow(game).to receive(:loading).and_return(false) }

    describe 'Track#auto_actions' do
      context 'when loading is true' do
        before { allow(game).to receive(:loading).and_return(true) }

        it 'returns [] regardless of destination state' do
          step.instance_variable_set(:@acted, true)
          allow(sfva).to receive(:destination_connected?).and_return(false)
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
        step.instance_variable_set(:@acted, true)
      end

      context 'when loading is true' do
        before { allow(game).to receive(:loading).and_return(true) }

        it 'does not include destination_connection' do
          allow(sfva).to receive(:destination_connected?).and_return(false)
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

    describe 'destination connection token release' do
      it 'clears the graph cache for the entity after goal_reached!' do
        action = Engine::Action::DestinationConnection.new(sfva, corporations: [sfva])
        expect(game).to receive(:clear_graph_for_entity).with(sfva).and_call_original
        step.process_destination_connection(action)
      end
    end
  end

  describe '18ESP_destination_token_release' do
    # Live-game repro: AVT lays tile at L22 connecting destination.
    # CDC (before Track in step order) auto-processes destination_connection
    # during strict loading. goal_reached! releases a blocked token.
    # Bug: without graph clear in CDC, can_token? returns stale false,
    # Track gets skipped, and place_token is lost.
    let(:game) { fixture_at_action(665) }
    let(:step) { game.round.steps.find { |s| s.is_a?(Engine::Game::G18ESP::Step::Track) } }
    let(:avt) { game.corporation_by_id('AVT') }

    it 'offers place_token after CDC processes destination_connection' do
      # CDC already processed destination_connection during fixture loading (strict: true → loading=false)
      expect(avt.destination_connected?).to eq(true)

      # The token released by goal_reached! must be visible
      expect(avt.tokens_by_type).not_to be_empty

      # Track must offer place_token (graph cache was cleared by CDC fix)
      expect(step.actions(avt)).to include('place_token')
    end
  end
end
