# frozen_string_literal: true

require './spec/spec_helper'

require 'json'
require 'timeout'

module Engine
  describe Game::G18EU do
    let(:players) { %w[a b c] }

    let(:actions) do
      [
        { 'type' => 'bid', 'entity' => 'a', 'entity_type' => 'player', 'minor' => '1', 'price' => 100, 'id' => 1 },
        { 'type' => 'pass', 'entity' => 'b', 'entity_type' => 'player', 'id' => 2 },
        { 'type' => 'bid', 'entity' => 'c', 'entity_type' => 'player', 'minor' => '1', 'price' => 410, 'id' => 3 },
        { 'type' => 'pass', 'entity' => 'a', 'entity_type' => 'player', 'id' => 4 },
        {
          'type' => 'program_auction_bid',
          'entity' => 'c',
          'entity_type' => 'player',
          'id' => 5,
          'bid_target' => '15',
          'enable_maximum_bid' => false,
          'maximum_bid' => '100',
          'enable_buy_price' => true,
          'buy_price' => '60',
          'auto_pass_after' => false,
        },
        { 'type' => 'bid', 'entity' => 'b', 'entity_type' => 'player', 'minor' => '2', 'price' => 100, 'id' => 6 },
      ]
    end

    # issue 9615
    # with the right combination of auto actions and player order, the auto actions could enter an infinite loop
    # of continuous Pass actions.  This test creates those conditions, attempting to trigger the loop,
    # but protected by a timeout.

    context '18EU programmed actions loop setup' do
      let(:players) { %w[a b c] }
      subject(:subject_with_actions) { Game::G18EU::Game.new(players, actions: actions) }

      it 'should not enter infinite loop' do
        expect(subject_with_actions.raw_actions.size).to be 6
        expect(subject_with_actions.current_entity.name).to be players[0]
        expect(subject.players.map(&:cash)).to eq([450, 450, 40])

        Timeout.timeout(10) do
          # Do not allow longer than 10 seconds to process pass action
          action = Engine::Action::Pass.new(subject_with_actions.current_entity)
          subject_with_actions.process_action(action, add_auto_actions: true)

          expect(subject_with_actions.raw_actions.size).to be 7
          expect(subject_with_actions.current_entity.name).to be players[2]
          expect(subject.players.map(&:cash)).to eq([450, 350, 40])
        end
      end
    end
  end
end
