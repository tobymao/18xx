# frozen_string_literal: true

require './spec/spec_helper'

require 'engine/action/bid'
require 'engine/round/auction'

module Engine
  describe Round::Auction do
    let(:player_1) { Player.new('a') }
    let(:player_2) { Player.new('b') }
    let(:players) { [player_1, player_2] }
    let(:game) { Game::G1889.new(players) }
    let(:bank) { game.bank }
    let(:private_1) { game.companies[0] }
    let(:private_2) { game.companies[1] }

    subject { Round::Auction.new(players, game: game) }

    before :each do
      bank.spend(100, player_1)
      bank.spend(100, player_2)
    end

    describe '#may_purchase?' do
      it 'is true for the cheapest, false for others' do
        expect(subject.may_purchase?(private_1)).to be true
        expect(subject.may_purchase?(private_2)).to be false
      end

      it 'is false if the cheapest has bids' do
        subject.process_action(Action::Bid.new(player_1, private_2, 35))
        subject.process_action(Action::Bid.new(player_2, private_2, 40))
        subject.process_action(Action::Bid.new(player_1, private_1, 20))
        expect(subject.may_purchase?(private_2)).to be false
      end

      it 'is true if the cheapest remaining has no bids' do
        subject.process_action(Action::Bid.new(player_1, private_1, 20))
        expect(subject.may_purchase?(private_2)).to be true
      end
    end

    describe '#process_action' do
      it 'buys the cheapest private' do
        subject.process_action(Action::Bid.new(player_1, private_1, 20))
        expect(player_1.companies).to eq([private_1])
        expect(player_1.cash).to eq(80)
        expect(bank.cash).to eq(5980)
      end

      it 'resolves waterfall' do
        subject.process_action(Action::Bid.new(player_1, private_2, 35))
        expect(player_1.companies).to eq([])
        expect(player_1.cash).to eq(100)

        subject.process_action(Action::Bid.new(player_2, private_1, 20))
        expect(player_2.companies).to eq([private_1])
        expect(player_2.cash).to eq(80)
        expect(player_1.companies).to eq([private_2])
        expect(player_1.cash).to eq(65)
      end
    end
  end
end
