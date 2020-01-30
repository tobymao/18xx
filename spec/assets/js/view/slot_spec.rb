# frozen_string_literal: true

require './spec/spec_helper'
require 'engine/corporation'
require 'engine/token'
require 'view/slot'

module View
  describe Slot do
    before do
      # mock for Native.convert used in Snabberb::Component
      stub_const('Native', double('Class', convert: ''))
    end

    describe '#render_token' do
      it 'returns nil if the token is nil' do
        slot = described_class.new(nil, game: nil, token: nil, city: nil)
        actual = slot.render_token

        expect(actual).to be_nil
      end

      it "renders the corporation's sym when a token is given" do
        corp = Engine::Corporation::Base.new('ER', name: 'Example Railroad', tokens: 1)
        token = corp.tokens.first

        slot = described_class.new(nil, game: nil, token: token, city: nil)
        allow(slot).to receive_messages(h: '')

        slot.render_token

        expect(slot).to have_received(:h).with(anything, anything, 'ER')
      end
    end
  end
end
