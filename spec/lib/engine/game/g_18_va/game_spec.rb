# frozen_string_literal: true

require 'spec_helper'

module Engine
  describe Game::G18VA::Game do
    let(:players) { %w[a b c] }
    subject { described_class.new(players, actions: actions) }

    let(:c_programs) { subject.programmed_actions[subject.player_by_id('c')] }

    # "Auto pass" (Action::ProgramSharePass) in the private auction passes until
    # outbid. The happy path is replayed by the 18VA/auto_auction_pass.json fixture.
    context 'auto pass in the auction' do
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

      def arm(id, unconditional: false)
        {
          'type' => 'program_share_pass',
          'entity' => 'c',
          'entity_type' => 'player',
          'id' => id,
          'unconditional' => unconditional,
          'indefinite' => false,
        }
      end

      def auto_action_types
        subject.raw_actions.last['auto_actions'].map { |a| a['type'] }
      end

      context 'with no winning bid to defend' do
        let(:actions) { [bid('a', 'P1', 40, 1), arm(2)] }

        it 'shows the auto pass button' do
          expect(subject.round.show_auto?).to be(true)
        end

        it 'auto-passes and keeps the program armed' do
          expect(subject.current_entity.name).to eq('b')
          subject.process_action(Engine::Action::Bid.new(subject.current_entity, company: subject.company_by_id('P1'),
                                                                                 price: 45),
                                 add_auto_actions: true)

          expect(auto_action_types).to eq(['pass'])
          expect(subject.raw_actions.last['auto_actions'].first['entity']).to eq('c')
          expect(c_programs.first).to be_a(Engine::Action::ProgramSharePass)
        end
      end

      context 'when outbid on a company led when armed' do
        let(:base_actions) { [bid('a', 'P2', 60, 1), bid('b', 'P3', 80, 2), bid('c', 'P1', 40, 3)] }
        let(:actions) { [*base_actions, arm(4), bid('a', 'P1', 45, 5)] }

        it 'disables the program and hands control back' do
          expect(subject.current_entity.name).to eq('b')
          subject.process_action(Engine::Action::Pass.new(subject.current_entity), add_auto_actions: true)

          expect(auto_action_types).to eq(['program_disable'])
          expect(c_programs).to be_empty
          expect(subject.current_entity.name).to eq('c')
        end

        context 'with an unconditional program' do
          let(:actions) { [*base_actions, arm(4, unconditional: true), bid('a', 'P1', 45, 5)] }

          it 'keeps passing' do
            subject.process_action(Engine::Action::Pass.new(subject.current_entity), add_auto_actions: true)

            expect(auto_action_types).to eq(['pass'])
            expect(c_programs.first).to be_a(Engine::Action::ProgramSharePass)
          end
        end
      end

      context 'when the auction resolves to completion' do
        # Every company (including the B&O presidency, P4) has a bid, so one pass
        # cycle resolves the whole auction.
        let(:actions) do
          [bid('a', 'P1', 45, 1), bid('b', 'P2', 65, 2), bid('c', 'P3', 85, 3), bid('a', 'P4', 140, 4), arm(5)]
        end

        it 'keeps the program through the presidency par, then drops it before the stock round' do
          subject.process_action(Engine::Action::Pass.new(subject.current_entity), add_auto_actions: true)
          subject.process_action(Engine::Action::Pass.new(subject.current_entity), add_auto_actions: true)

          expect(subject.round).to be_auction
          expect(subject.round.companies_pending_par.map(&:name)).to eq(['Baltimore & Ohio Presidency'])
          expect(c_programs.first).to be_a(Engine::Action::ProgramSharePass)

          share_price = subject.stock_market.par_prices.min_by(&:price)
          subject.process_action(
            Engine::Action::Par.new(subject.current_entity, corporation: subject.corporation_by_id('B&O'),
                                                            share_price: share_price)
          )

          expect(subject.round).to be_stock
          expect(c_programs).to be_empty
        end
      end
    end
  end
end
