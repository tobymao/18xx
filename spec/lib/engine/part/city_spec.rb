# frozen_string_literal: true

require './spec/spec_helper'
require 'engine/corporation/base'
require 'engine/part/city'
require 'engine/token'

module Engine
  module Part
    describe City do
      subject { described_class.new(20) }

      let(:corporation) { Engine::Corporation::Base.new('AS', name: 'Aperture Science', tokens: 2) }
      let(:placed_token) { Engine::Token.new(corporation, true) }
      let(:unplaced_token) { Engine::Token.new(corporation) }

      describe '#initialize' do
        it 'starts with no tokens' do
          expect(subject.tokens).to eq([nil])
        end
      end

      describe '#place_token' do
        it 'does not update the tokens when there is already a token in the slot' do
          subject.place_token(corporation, 0)
          expect(subject.tokens).to eq([placed_token])

          subject.place_token(corporation, 0)
          expect(subject.tokens).to eq([placed_token])
        end

        it "places the corporation's first unplaced token" do
          expect(corporation.tokens).to eq([unplaced_token, unplaced_token])

          subject.place_token(corporation, 0)

          expect(corporation.tokens).to eq([placed_token, unplaced_token])
          expect(subject.tokens).to eq([placed_token])
        end
      end
    end
  end
end
