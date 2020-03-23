# frozen_string_literal: true

require './spec/spec_helper'
require 'engine/corporation'
require 'view/token'
require 'view/slot'

module View
  describe Slot do
    before do
      # mock for Native.convert used in Snabberb::Component
      stub_const('Native', double('Class', convert: ''))
    end

    describe '#render' do
      context 'with token' do
        it 'renders a View::Token' do
          # setup
          corp = Engine::Corporation.new('ER', name: 'Example Railroad', tokens: 1)
          token = corp.tokens.first
          radius = 1
          slot = described_class.new(nil, token: token, game: nil, city: nil, radius: radius, connection: double)
          allow(slot).to receive_messages(h: '')

          # act
          slot.render

          # assert
          expect(slot).to have_received(:h).with(View::Token, corporation: corp, radius: radius)
        end
      end

      context 'with no token' do
        it 'does not render a View::Token' do
          # setup
          slot = described_class.new(nil, token: nil, game: nil, city: nil, radius: 0, connection: double)
          allow(slot).to receive_messages(h: '')

          # act
          slot.render

          # assert
          expect(slot).not_to have_received(:h).with(Token, anything)
        end
      end
    end
  end
end
