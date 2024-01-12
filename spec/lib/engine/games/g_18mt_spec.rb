# frozen_string_literal: true

require './spec/spec_helper'

require 'json'

module Engine
  describe Game::G18MT do
    let(:players) { %w[a b c] }

    let(:actions) do
      [
        {
          'type' => 'program_auction_bid',
          'entity' => 'c',
          'entity_type' => 'player',
          'id' => 1,
          'bid_target' => 'GP',
          'enable_maximum_bid' => false,
          'maximum_bid' => '20',
          'enable_buy_price' => true,
          'buy_price' => '15',
          'auto_pass_after' => false,
        },
        { 'type' => 'bid', 'entity' => 'a', 'entity_type' => 'player', 'company' => 'GV', 'price' => 35, 'id' => 2 },

      ]
    end

    context '18MT programmed actions step' do
      let(:players) { %w[a b c] }
      subject(:subject_with_actions) { Game::G18MT::Game.new(players, actions: actions) }

      it 'should pass if pass is an option' do
        expect(subject_with_actions.raw_actions.size).to be 2
        action = Engine::Action::Bid.new(subject_with_actions.current_entity, company: subject_with_actions.company_by_id('MW'),
                                                                              price: 45)
        subject_with_actions.process_action(action, add_auto_actions: true)

        expect(subject_with_actions.raw_actions.size).to be 3
        expect(subject_with_actions.current_entity.name).to be players[0]
      end
    end
  end
end
