# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1867::Game do
  describe 'nationalization_cash' do
    # action 528: CNR nationalized to Bank with $372
    [0, 1, 527, 528, 668].each do |action|
      it "total cash in play matches BANK_CASH at action #{action}" do
        game = fixture_at_action(action)

        total_cash = %i[bank players corporations minors national].sum do |entities|
          Array(game.send(entities)).sum(&:cash)
        end

        expect(total_cash).to eq(game.class::BANK_CASH)
      end
    end
  end
end
