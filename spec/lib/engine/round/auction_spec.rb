# frozen_string_literal: true

require './spec/spec_helper'

require 'engine/action/bid'
require 'engine/game/g_1889'
require 'engine/player'
require 'engine/round/auction'

module Engine
  describe Round::Auction do
    let(:player_1) { Player.new('a') }
    let(:player_2) { Player.new('b') }
    let(:player_3) { Player.new('c') }
    let(:players) { [player_1, player_2, player_3] }

    let(:game) do
      game = Game::G1889.new(players)
      game.companies.slice!(3..-1)
      players.each { |player| game.bank.spend(100, player) }
      game
    end

    let(:private_1) { game.companies[0] }
    let(:private_2) { game.companies[1] }
    let(:private_3) { game.companies[2] }

    subject { Round::Auction.new(players, game: game) }

    describe '#may_purchase?' do
      it 'is true for the cheapest, false for others' do
        expect(subject.may_purchase?(private_1)).to be true
        game.companies[1..-1].each do |company|
          expect(subject.may_purchase?(company)).to be false
        end
      end

      it 'is false if the cheapest has bids' do
        subject.process_action(Action::Bid.new(player_1, private_2, 35))
        subject.process_action(Action::Bid.new(player_2, private_2, 40))
        subject.process_action(Action::Bid.new(player_3, private_1, 20))
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
        expect(game.bank.cash).to eq(5460)
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

        expect(subject.current_player).to eq(player_3)
      end

      it 'preserves order on waterfall pass' do
        subject.process_action(Action::Bid.new(player_1, private_2, 35))
        subject.process_action(Action::Bid.new(player_2, private_2, 40))
        subject.process_action(Action::Bid.new(player_3, private_1, 20))
        subject.process_action(Action::Pass.new(player_1))
        expect(subject.current_player).to eq(player_1)
      end

      it 'preserves priority' do
        subject.process_action(Action::Bid.new(player_1, private_1, 20))
        subject.process_action(Action::Bid.new(player_2, private_2, 30))
        subject.process_action(Action::Bid.new(player_3, private_3, 40))
        expect(subject.last_to_act).to eq(player_3)
      end
    end
  end
end
