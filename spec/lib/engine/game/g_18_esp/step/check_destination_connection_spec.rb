# frozen_string_literal: true

require 'spec_helper'

# fixture_at_action derives the game title from the outermost describe class (.title),
# so this spec must be rooted at the Game class rather than the Step class.
describe Engine::Game::G18ESP::Game do
  describe '18ESP_game_end_second_eight' do
    describe Engine::Game::G18ESP::Step::CheckDestinationConnection do
      # at_action 106: SFVA is floated, goals_reached_counter=0, destination_connected=false.
      # Action 107 is the first action that causes SFVA to reach its destination, so 106
      # is the latest point where destination logic can be exercised without state mutation.
      let(:game) { fixture_at_action(106) }
      let(:sfva) { game.corporation_by_id('SFVA') }

      def stub_live_play
        allow(game).to receive(:loading).and_return(false)
      end

      def stub_loading
        allow(game).to receive(:loading).and_return(true)
      end

      describe '#actions' do
        before { allow(game.round).to receive(:current_entity).and_return(sfva) }

        context 'live play' do
          before { stub_live_play }

          it 'returns ACTIONS when corp is not yet connected and check passes' do
            allow(sfva).to receive(:destination_connected?).and_return(false)
            allow(game).to receive(:check_for_destination_connection).with(sfva).and_return(true)
            expect(described_class.new(game, game.round).actions(sfva)).to eq(%w[destination_connection])
          end

          it 'returns [] when corp is already destination_connected?' do
            allow(sfva).to receive(:destination_connected?).and_return(true)
            expect(described_class.new(game, game.round).actions(sfva)).to eq([])
          end

          it 'returns [] when check_for_destination_connection returns false' do
            allow(sfva).to receive(:destination_connected?).and_return(false)
            allow(game).to receive(:check_for_destination_connection).with(sfva).and_return(false)
            expect(described_class.new(game, game.round).actions(sfva)).to eq([])
          end

          it 'returns [] for a non-current entity' do
            other = game.corporations.find { |c| c != sfva }
            expect(described_class.new(game, game.round).actions(other)).to eq([])
          end
        end

        context 'when loading' do
          before { stub_loading }

          it 'returns ACTIONS when corp is newly connected — sub-action waits in log' do
            allow(sfva).to receive(:destination_connected?).and_return(false)
            allow(game).to receive(:check_for_destination_connection).with(sfva).and_return(true)
            expect(described_class.new(game, game.round).actions(sfva)).to eq(%w[destination_connection])
          end

          it 'returns [] when corp is already connected' do
            allow(sfva).to receive(:destination_connected?).and_return(true)
            expect(described_class.new(game, game.round).actions(sfva)).to eq([])
          end
        end
      end

      describe '#auto_actions' do
        context 'live play' do
          before { stub_live_play }

          it 'emits DestinationConnection with the corporation when newly connected' do
            allow(sfva).to receive(:destination_connected?).and_return(false)
            allow(game).to receive(:check_for_destination_connection).with(sfva).and_return(true)
            action = described_class.new(game, game.round).auto_actions(sfva).first
            expect(action).to be_a(Engine::Action::DestinationConnection)
            expect(action.corporations).to eq([sfva])
          end

          it 'returns [] when corp is already destination_connected?' do
            allow(sfva).to receive(:destination_connected?).and_return(true)
            expect(described_class.new(game, game.round).auto_actions(sfva)).to eq([])
          end

          it 'returns [] when check_for_destination_connection returns false' do
            allow(sfva).to receive(:destination_connected?).and_return(false)
            allow(game).to receive(:check_for_destination_connection).with(sfva).and_return(false)
            expect(described_class.new(game, game.round).auto_actions(sfva)).to eq([])
          end

          it 'returns [] for a non-corporation entity' do
            expect(described_class.new(game, game.round).auto_actions(nil)).to eq([])
          end
        end

        context 'when loading' do
          before { stub_loading }

          # blocking? is false during loading, so the framework never calls auto_actions on CDC.
          # Standalone destination_connection actions in the log are routed via process_action.
          it 'returns [] — CDC is non-blocking during load' do
            allow(sfva).to receive(:destination_connected?).and_return(false)
            allow(game).to receive(:check_for_destination_connection).with(sfva).and_return(true)
            expect(described_class.new(game, game.round).auto_actions(sfva)).to eq([])
          end

          it 'returns [] when corp is already connected' do
            allow(sfva).to receive(:destination_connected?).and_return(true)
            expect(described_class.new(game, game.round).auto_actions(sfva)).to eq([])
          end
        end
      end

      describe '#process_destination_connection' do
        it 'calls goal_reached!(:destination) on the corporation in action.corporations.first' do
          action = Engine::Action::DestinationConnection.new(sfva, corporations: [sfva])
          expect(sfva).to receive(:goal_reached!).with(:destination)
          described_class.new(game, game.round).process_destination_connection(action)
        end

        it 'sets @passed to true' do
          action = Engine::Action::DestinationConnection.new(sfva, corporations: [sfva])
          step_obj = described_class.new(game, game.round)
          expect { step_obj.process_destination_connection(action) }
            .to change { step_obj.passed? }.from(nil).to(true)
        end

        it 'processes only corporations.first, not the full list — single-entity invariant' do
          other = game.corporations.find { |c| c != sfva }
          action = Engine::Action::DestinationConnection.new(sfva, corporations: [sfva, other])
          expect(sfva).to receive(:goal_reached!).with(:destination)
          expect(other).not_to receive(:goal_reached!)
          described_class.new(game, game.round).process_destination_connection(action)
        end
      end

      describe '#pass!' do
        it 'is a no-op — does not set @passed' do
          step_obj = described_class.new(game, game.round)
          step_obj.pass!
          expect(step_obj.passed?).to be_falsy
        end
      end
    end
  end
end
