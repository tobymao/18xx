# frozen_string_literal: true

require './spec/spec_helper'

require 'engine/phase'
require 'engine/round/handler'
require 'engine/round/operating'

module Engine
  describe Round::Handler do
    describe '#finish!' do
      let(:players) { [Player.new('a'), Player.new('b')] }
      let(:privates) { [Company::Base.new('private', value: 10, income: 5)] }
      let(:auction) { Round::PrivateAuction.new(players, companies: privates) }
      let(:stock) { Round::Stock.new(players) }
      let(:or_1) { Round::Operating.new(players) }
      let(:or_2) { Round::Operating.new(players, num: 2) }
      let(:green_phase) { Phase.green }

      subject { Round::Handler.new(players, privates) }

      it 'advances to the proper round' do
        [
          [auction, Round::Stock],
          [stock, Round::Operating],
          [or_1, Round::Operating],
          [or_2, Round::Stock],
        ].each do |current, next_type|
          subject.current = current
          expect { subject.finish!(green_phase) }.to change {
            subject.current
          }.from(current).to(next_type)
        end
      end
    end
  end
end
