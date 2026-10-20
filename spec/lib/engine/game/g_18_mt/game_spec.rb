# frozen_string_literal: true

require 'spec_helper'

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

  describe Game::G18MT::Game do
    let(:players) { %w[a b c] }
    subject { described_class.new(players, actions: actions) }

    let(:a_programs) { subject.programmed_actions[subject.player_by_id('a')] }

    # Regression coverage for Step::ProgrammerAuctionBid#auto_already_high_bid
    # (lib/engine/step/programmer_auction_bid.rb), shared by every game with
    # Action::ProgramAuctionBid (18EU, 18MT, 18VA) via the plain
    # Engine::Step::WaterfallAuction. 18MT uses that base step unmodified, so
    # unlike 18VA it must fully disable the program once outbid-by-self rather
    # than keep cycling, or an armed program that reaches this branch with
    # `auto_pass_after: false` would auto-pass forever (the turn never actually
    # advances past the auction), hanging the game.
    context 'programmed auction bid, already the high bidder' do
      def bid(entity, company, price, id)
        {
          'type' => 'bid',
          'entity' => entity,
          'entity_type' => 'player',
          'company' => company,
          'price' => price,
          'id' => id,
        }
      end

      def arm(id, auto_pass_after:)
        {
          'type' => 'program_auction_bid',
          'entity' => 'a',
          'entity_type' => 'player',
          'bid_target' => 'GV',
          'maximum_bid' => 0,
          'buy_price' => 0,
          'enable_maximum_bid' => false,
          'enable_buy_price' => false,
          'auto_pass_after' => auto_pass_after,
          'id' => id,
        }
      end

      # a bids on Gallatin Valley Railway (not the cheapest company, so the bid
      # doesn't auto-resolve), b bids on Montana Western so the turn keeps
      # moving, then a arms a program targeting GV before the turn cycles back
      # around to a while a is still GV's sole/high bidder.
      let(:common_actions) { [bid('a', 'GV', 35, 1), bid('b', 'MW', 45, 2), arm(3, auto_pass_after: auto_pass_after)] }
      let(:actions) { common_actions }

      context 'with auto_pass_after: false (no "otherwise auto pass" opt-in)' do
        let(:auto_pass_after) { false }

        it 'disables the program instead of looping forever' do
          subject.process_action(Engine::Action::Pass.new(subject.player_by_id('c')), add_auto_actions: true)

          auto_actions = subject.raw_actions.last['auto_actions']
          expect(auto_actions.map { |a| a['type'] }).to eq(['program_disable'])
          expect(a_programs).to be_empty
          expect(subject.current_entity.name).to eq('a')
        end
      end

      context 'with auto_pass_after: true' do
        let(:auto_pass_after) { true }

        it 'stays armed and passes on behalf of the player' do
          subject.process_action(Engine::Action::Pass.new(subject.player_by_id('c')), add_auto_actions: true)

          auto_actions = subject.raw_actions.last['auto_actions']
          expect(auto_actions.map { |a| a['type'] }).to eq(['pass'])
          expect(a_programs.first).to be_a(Engine::Action::ProgramAuctionBid)
        end
      end
    end
  end
end
