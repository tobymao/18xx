# frozen_string_literal: true

require './spec/spec_helper'

require 'engine/action/bid'
require 'engine/game/g_1889'
require 'engine/player'
require 'engine/round/auction'
require 'engine/step/waterfall_auction'

module Engine
  describe Round::Auction do
    let(:game) do
      game = Game::G1889.new(%w[a b c])
      game.companies.slice!(3..-1)
      game
    end

    let(:player_1) { game.player_by_id('a') }
    let(:player_2) { game.player_by_id('b') }
    let(:player_3) { game.player_by_id('c') }

    let(:private_1) { game.companies[0] }
    let(:private_2) { game.companies[1] }
    let(:private_3) { game.companies[2] }

    subject { Round::Auction.new(game, [Step::WaterfallAuction]) }

    describe 'current_entity' do
      it 'should start with player 1' do
        expect(subject.current_entity).to eq(player_1)
      end

      it 'bidding moves to next player' do
        subject.process_action(Action::Bid.new(player_1, company: private_2, price: 35))
        expect(subject.current_entity).to eq(player_2)
      end
    end

    describe '#may_purchase?' do
      it 'is true for the cheapest, false for others' do
        expect(subject.active_step.may_purchase?(private_1)).to be true
        game.companies[1..-1].each do |company|
          expect(subject.active_step.may_purchase?(company)).to be false
        end
      end

      it 'is false if the cheapest has bids' do
        subject.process_action(Action::Bid.new(player_1, company: private_2, price: 35))
        subject.process_action(Action::Bid.new(player_2, company: private_2, price: 40))
        subject.process_action(Action::Bid.new(player_3, company: private_1, price: 20))
        expect(subject.active_step.may_purchase?(private_2)).to be false
      end

      it 'is true if the cheapest remaining has no bids' do
        subject.process_action(Action::Bid.new(player_1, company: private_1, price: 20))
        expect(subject.active_step.may_purchase?(private_2)).to be true
      end
    end

    describe '#process_action' do
      it 'buys the cheapest private' do
        subject.process_action(Action::Bid.new(player_1, company: private_1, price: 20))
        expect(player_1.companies).to eq([private_1])
        expect(player_1.cash).to eq(400)
        expect(game.bank.cash).to eq(5760)
      end

      it 'resolves waterfall' do
        subject.process_action(Action::Bid.new(player_1, company: private_2, price: 35))
        expect(player_1.companies).to eq([])
        expect(player_1.cash).to eq(420)

        subject.process_action(Action::Bid.new(player_2, company: private_1, price: 20))
        expect(player_2.companies).to eq([private_1])
        expect(player_2.cash).to eq(400)
        expect(player_1.companies).to eq([private_2])
        expect(player_1.cash).to eq(385)

        expect(subject.current_entity).to eq(player_3)
      end

      it 'preserves order on waterfall pass' do
        subject.process_action(Action::Bid.new(player_1, company: private_2, price: 35))
        subject.process_action(Action::Bid.new(player_2, company: private_2, price: 40))
        subject.process_action(Action::Bid.new(player_3, company: private_1, price: 20))
        subject.process_action(Action::Pass.new(player_1))
        expect(subject.current_entity).to eq(player_1)
      end

      it 'preserves priority' do
        subject.process_action(Action::Bid.new(player_1, company: private_1, price: 20))
        subject.process_action(Action::Bid.new(player_2, company: private_2, price: 30))
        subject.process_action(Action::Bid.new(player_3, company: private_3, price: 40))
        expect(subject.index).to eq(0)
      end

      it 'allows passers to come back in' do
        subject.process_action(Action::Bid.new(player_1, company: private_2, price: 35))
        subject.process_action(Action::Bid.new(player_2, company: private_2, price: 40))
        subject.process_action(Action::Pass.new(player_3))
        subject.process_action(Action::Bid.new(player_1, company: private_3, price: 45))
        subject.process_action(Action::Bid.new(player_2, company: private_3, price: 50))
        expect(subject.current_entity).to eq(player_3)
      end

      it 'all passing should decrease private value' do
        subject.process_action(Action::Pass.new(player_1))
        subject.process_action(Action::Pass.new(player_2))
        subject.process_action(Action::Pass.new(player_3))
        expect(subject.current_entity).to eq(player_1)
        expect(private_1.min_bid).to eq(15)
      end
    end
  end
end
