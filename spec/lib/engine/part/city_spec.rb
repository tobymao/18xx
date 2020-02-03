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
    end
  end
end
