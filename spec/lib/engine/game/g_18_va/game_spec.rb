# frozen_string_literal: true

require 'spec_helper'

module Engine
  describe Game::G18VA::Game do
    let(:players) { %w[a b c] }
    subject { described_class.new(players, actions: actions) }

    let(:c_programs) { subject.programmed_actions[subject.player_by_id('c')] }

    # "Auto-pass unless outbid" (Action::ProgramAuctionPass). The happy path
    # (arm, auto-pass, program survives) is replayed end-to-end by the
    # 18VA/auto_auction_pass.json and auto_auction_bid.json fixtures; these
    # cover the two branches those fixtures don't reach.
    context 'programmed auction pass' do
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

      def arm(id)
        { 'type' => 'program_auction_pass', 'entity' => 'c', 'entity_type' => 'player', 'id' => id }
      end

      context 'with no winning bid to defend' do
        # c never bids; a and b fight over P1 while c just wants out.
        let(:actions) { [bid('a', 'P1', 40, 1), arm(2)] }

        it 'auto-passes anyway and keeps the program armed' do
          expect(subject.current_entity.name).to eq('b')
          subject.process_action(Engine::Action::Bid.new(subject.current_entity, company: subject.company_by_id('P1'),
                                                                                 price: 45),
                                 add_auto_actions: true)

          auto_actions = subject.raw_actions.last['auto_actions']
          expect(auto_actions.map { |a| a['type'] }).to eq(['pass'])
          expect(auto_actions.first['entity']).to eq('c')
          expect(c_programs.first).to be_a(Engine::Action::ProgramAuctionPass)
        end
      end

      context 'when outbid on a defended company' do
        # c is winning P1 when it arms, then a tops it.
        let(:actions) { [bid('a', 'P2', 60, 1), bid('b', 'P3', 80, 2), bid('c', 'P1', 40, 3), arm(4), bid('a', 'P1', 45, 5)] }

        it 'disables the program and hands control back' do
          expect(subject.current_entity.name).to eq('b')
          subject.process_action(Engine::Action::Pass.new(subject.current_entity), add_auto_actions: true)

          auto_actions = subject.raw_actions.last['auto_actions']
          expect(auto_actions.map { |a| a['type'] }).to eq(['program_disable'])
          expect(c_programs).to be_empty
          expect(subject.current_entity.name).to eq('c')
        end
      end
    end
  end
end
