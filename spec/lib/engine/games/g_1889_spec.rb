# frozen_string_literal: true

require './spec/spec_helper'

require 'engine/game/g_1889'
require 'engine/part/city'

module Engine
  describe Game::G1889 do
    let(:players) { [Player.new('a'), Player.new('b')] }
    subject { Game::G1889.new(players) }

    context 'on init' do
      it 'starts with correct cash' do
        expect(subject.bank.cash).to eq(6160)
        expect(subject.players.map(&:cash)).to eq([420, 420])
      end

      it 'starts with an auction' do
        expect(subject.round).to be_a(Round::Auction)
      end
    end

    # describe '#next_round!' do
    #   let(:bank) { Bank.new(1000) }
    #   let(:players) { [Player.new('a'), Player.new('b')] }
    #   let(:privates) { [Company::Base.new('private', value: 10, income: 5)] }
    #   let(:auction) { Round::Auction.new(players, companies: privates) }
    #   let(:stock) { Round::Stock.new(players) }
    #   let(:or_1) { Round::Operating.new(players) }
    #   let(:or_2) { Round::Operating.new(players, num: 2) }
    #   let(:green_phase) { Phase.green }

    #   it 'advances to the proper round' do
    #     [
    #       [auction, Round::Stock],
    #       [stock, Round::Operating],
    #       [or_1, Round::Operating],
    #       [or_2, Round::Stock],
    #     ].each do |current, next_type|
    #       subject.current = current
    #       expect { subject.finish!(green_phase) }.to change {
    #         subject.current
    #       }.from(current).to(next_type)
    #     end
    #   end
    # end
  end
end
