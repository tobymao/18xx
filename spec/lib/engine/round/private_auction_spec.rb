# frozen_string_literal: true

require './spec/spec_helper'

require 'engine/action/bid'
require 'engine/round/private_auction'

module Engine
  describe Round::PrivateAuction do
    let(:bank) { Bank.new(1000) }
    let(:player_1) { Player.new('a') }
    let(:player_2) { Player.new('b') }
    let(:private_1) { Company::Base.new('c_1', value: 10, income: 5) }
    let(:private_2) { Company::Base.new('c_2', value: 20, income: 10) }

    subject { Round::PrivateAuction.new([player_1, player_2], bank: bank, companies: [private_1, private_2]) }

    before :each do
      player_1.add_cash(100)
      player_2.add_cash(100)
    end

    describe '#process_action' do
      it 'buys the cheapest private' do
        subject.process_action(Action::Bid.new(player_1, private_1, 10))
        expect(player_1.companies).to eq([private_1])
        expect(player_1.cash).to eq(90)
        expect(bank.cash).to eq(1010)
      end

      it 'resolves waterfall' do
        subject.process_action(Action::Bid.new(player_1, private_2, 20))
        expect(player_1.companies).to eq([])
        expect(player_1.cash).to eq(100)

        subject.process_action(Action::Bid.new(player_2, private_1, 5))
        expect(player_2.companies).to eq([private_1])
        expect(player_2.cash).to eq(95)
        expect(player_1.companies).to eq([private_2])
        expect(player_1.cash).to eq(80)
      end
    end
  end
end
