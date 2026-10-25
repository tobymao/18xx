# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1835::Game do
  describe 'baden_is_forced_to_place_home_token_during_stock_round' do
    it 'forces Baden to place home token during stock round' do
      game = fixture_at_action(365)

      expect(game.current_entity).to eq(game.corporation_by_id('BA'))
      expect(game.round.active_step).to be_a(Engine::Step::HomeToken)

    end
  end

  # Weitere tests:
  # - Nicht manuell Pöppeln, bevor Baden in Betrieb
  # - nicht mit PfB pöppeln, bevor Baden in Betrieb
  # - Wenn Baden in Betrieb, muss Home Token setzen, sobald L6 bebaut
end
