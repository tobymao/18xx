# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G18ESP::Step::CheckDestinationConnection do
  # Game loaded at action 106: SFVA not yet destination-connected (first
  # destination goal is logged at action 107). FdSB also not yet connected.
  let(:fixture_data) { JSON.parse(File.read("#{FIXTURES_DIR}/18ESP/18ESP_game_end_second_eight.json")) }
  let(:game)   { Engine::Game.load(fixture_data, at_action: 106, strict: false) }
  let(:step)   { described_class.new(game, game.round) }
  let(:corp)   { game.corporation_by_id('SFVA') }
  let(:player) { game.players.first }

  describe '#actions' do
    it 'returns destination_connection for any entity' do
      expect(step.actions(nil)).to eq(%w[destination_connection])
      expect(step.actions(corp)).to eq(%w[destination_connection])
      expect(step.actions(player)).to eq(%w[destination_connection])
    end
  end

  describe '#auto_actions' do
    context 'with a non-corporation entity' do
      it 'returns [] for nil' do
        expect(step.auto_actions(nil)).to eq([])
      end

      it 'returns [] for a player' do
        expect(step.auto_actions(player)).to eq([])
      end
    end

    context 'when the corporation has no destination connection' do
      # SFVA.destination_connected is false at action 106 and graph confirms
      # it is not yet reachable, so check_for_destination_connection returns false.
      it 'emits one DestinationConnection action with an empty corporations list' do
        result = step.auto_actions(corp)

        expect(result.size).to eq(1)
        expect(result.first).to be_a(Engine::Action::DestinationConnection)
        expect(result.first.corporations).to eq([])
      end
    end

    context 'when the corporation already has a destination connection' do
      # Setting destination_connected=true short-circuits check_for_destination_connection
      # without needing graph computation.
      before { corp.destination_connected = true }

      it 'emits one DestinationConnection action with the corporation' do
        result = step.auto_actions(corp)

        expect(result.size).to eq(1)
        expect(result.first).to be_a(Engine::Action::DestinationConnection)
        expect(result.first.corporations).to eq([corp])
      end
    end
  end

  describe '#process_destination_connection' do
    let(:corp_a) { game.corporation_by_id('SFVA') }
    let(:corp_b) { game.corporation_by_id('FdSB') }

    it 'calls goal_reached!(:destination) on every corporation in the action' do
      action = Engine::Action::DestinationConnection.new(corp_a, corporations: [corp_a, corp_b])
      expect(corp_a).to receive(:goal_reached!).with(:destination)
      expect(corp_b).to receive(:goal_reached!).with(:destination)

      step.process_destination_connection(action)
    end

    it 'sets the step as passed after processing' do
      action = Engine::Action::DestinationConnection.new(corp_a, corporations: [])
      expect { step.process_destination_connection(action) }
        .to change { step.passed? }.from(nil).to(true)
    end
  end

  describe '#pass!' do
    it 'is a no-op that does not mark the step as passed' do
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
