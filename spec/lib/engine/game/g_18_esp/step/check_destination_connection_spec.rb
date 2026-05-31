# frozen_string_literal: true

require 'spec_helper'

# fixture_at_action derives the game title from the outermost describe
# class (.title), so this spec must be rooted at the Game class rather
# than the Step class.
describe Engine::Game::G18ESP::Game do
  describe '18ESP_game_end_second_eight' do
    describe Engine::Game::G18ESP::Step::CheckDestinationConnection do
      # at_action 106: SFVA is floated, goals_reached_counter=0,
      # destination_connected=false. Action 107 is the first action that
      # causes SFVA to reach its destination, so 106 is the latest point
      # where destination logic can be exercised without state mutation.
      let(:game)   { fixture_at_action(106) }
      let(:sfva)   { game.corporation_by_id('SFVA') }
      let(:player) { game.players.first }
      let(:step)   { described_class.new(game, game.round) }

      describe '#actions' do
        context 'during live play (game not loading)' do
          it 'returns ACTIONS when corp is not yet connected and check passes' do
            allow(sfva).to receive(:destination_connected?).and_return(false)
            allow(game).to receive(:check_for_destination_connection).with(sfva).and_return(true)
            expect(step.actions(sfva)).to eq(%w[destination_connection])
          end

          it 'returns [] when corp is already destination_connected?' do
            allow(sfva).to receive(:destination_connected?).and_return(true)
            expect(step.actions(sfva)).to eq([])
          end

          it 'returns [] when check_for_destination_connection returns false' do
            allow(sfva).to receive(:destination_connected?).and_return(false)
            allow(game).to receive(:check_for_destination_connection).with(sfva).and_return(false)
            expect(step.actions(sfva)).to eq([])
          end

          it 'returns [] for a non-corporation entity (nil)' do
            expect(step.actions(nil)).to eq([])
          end

          it 'returns [] for a player entity' do
            expect(step.actions(player)).to eq([])
          end
        end

        context 'when game is loading' do
          let(:game) { fixture_at_action(106, clear_cache: true) }
          before { game.instance_variable_set(:@loading, true) }

          it 'returns [] regardless of connection state' do
            allow(sfva).to receive(:destination_connected?).and_return(false)
            allow(game).to receive(:check_for_destination_connection).with(sfva).and_return(true)
            expect(step.actions(sfva)).to eq([])
          end
        end
      end

      describe '#auto_actions' do
        context 'during live play (game not loading)' do
          it 'emits DestinationConnection with the corporation when newly connected' do
            allow(sfva).to receive(:destination_connected?).and_return(false)
            allow(game).to receive(:check_for_destination_connection).with(sfva).and_return(true)
            result = step.auto_actions(sfva)
            expect(result.size).to eq(1)
            expect(result.first).to be_a(Engine::Action::DestinationConnection)
            expect(result.first.corporations).to eq([sfva])
          end

          it 'returns [] when corp is already destination_connected?' do
            allow(sfva).to receive(:destination_connected?).and_return(true)
            expect(step.auto_actions(sfva)).to eq([])
          end

          it 'returns [] when check_for_destination_connection returns false' do
            allow(sfva).to receive(:destination_connected?).and_return(false)
            allow(game).to receive(:check_for_destination_connection).with(sfva).and_return(false)
            expect(step.auto_actions(sfva)).to eq([])
          end

          it 'returns [] for a non-corporation entity (nil)' do
            expect(step.auto_actions(nil)).to eq([])
          end

          it 'returns [] for a player entity' do
            expect(step.auto_actions(player)).to eq([])
          end
        end

        context 'when game is loading' do
          let(:game) { fixture_at_action(106, clear_cache: true) }
          before { game.instance_variable_set(:@loading, true) }

          it 'returns [] even when corp is newly connected' do
            allow(sfva).to receive(:destination_connected?).and_return(false)
            allow(game).to receive(:check_for_destination_connection).with(sfva).and_return(true)
            expect(step.auto_actions(sfva)).to eq([])
          end
        end
      end

      describe '#process_destination_connection' do
        it 'calls goal_reached!(:destination) on action.corporations.first' do
          action = Engine::Action::DestinationConnection.new(sfva, corporations: [sfva])
          expect(sfva).to receive(:goal_reached!).with(:destination)
          step.process_destination_connection(action)
        end

        it 'sets @passed to true' do
          action = Engine::Action::DestinationConnection.new(sfva, corporations: [sfva])
          expect { step.process_destination_connection(action) }
            .to change { step.passed? }.from(nil).to(true)
        end

        it 'processes only corporations.first, not the full list — single-entity invariant' do
          # auto_actions never emits more than one corp; this documents
          # that process_destination_connection is intentionally
          # single-entity so a future maintainer cannot silently switch
          # it back to .each without a failing test.
          other = game.corporations.find { |c| c != sfva }
          action = Engine::Action::DestinationConnection.new(sfva, corporations: [sfva, other])
          expect(sfva).to receive(:goal_reached!).with(:destination)
          expect(other).not_to receive(:goal_reached!)
          step.process_destination_connection(action)
        end
      end

      describe '#pass!' do
        it 'is a no-op — does not set @passed' do
          step.pass!
          expect(step.passed?).to be_falsy
        end
      end

      describe '#description' do
        it 'returns a non-empty string' do
          expect(step.description).to be_a(String)
          expect(step.description).not_to be_empty
        end
      end
    end
  end
end
