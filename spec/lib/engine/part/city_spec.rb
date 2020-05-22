# frozen_string_literal: true

require './spec/spec_helper'
require 'engine'
require 'engine/corporation'
require 'engine/part/city'
require 'engine/token'

module Engine
  module Part
    describe City do
      subject { described_class.new('20') }

      let(:corporation) { Engine::Corporation.new('AS', name: 'Aperture Science', tokens: 2) }
      let(:placed_token) { Engine::Token.new(corporation, true) }
      let(:unplaced_token) { Engine::Token.new(corporation) }

      describe '#initialize' do
        it 'starts with no tokens' do
          expect(subject.tokens).to eq([nil])
        end
      end

      describe '#exits' do
        it "returns the correct edges for 18Chesapeake's tile X3" do
          game = GAMES_BY_TITLE['18Chesapeake'].new(%w[a b c])
          x3 = game.tile_by_id('X3-0')
          expect(x3.cities[0].exits.sort).to eq([0, 2])
          expect(x3.cities[1].exits.sort).to eq([3, 5])

          x3.rotate!(1)
          expect(x3.cities[0].exits.sort).to eq([1, 3])
          expect(x3.cities[1].exits.sort).to eq([0, 4])
        end
      end
    end
  end
end
