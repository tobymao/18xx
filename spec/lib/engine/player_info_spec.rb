# frozen_string_literal: true

require 'spec_helper'

describe Engine::PlayerInfo do
  describe '#round' do
    it 'includes the round number for private closure rounds' do
      info = described_class.new('PCR', 5, 2, 100)

      expect(info.round).to eq('PCR 5.2')
    end

    it 'does not include the round number for stock rounds' do
      info = described_class.new('SR', 5, 1, 100)

      expect(info.round).to eq('SR 5')
    end
  end
end
