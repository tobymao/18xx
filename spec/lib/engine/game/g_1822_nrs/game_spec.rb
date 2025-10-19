# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1822NRS::Game do
  describe 128_129 do
    it 'ability_combo_entities should not throw an error when one of the combo entities was removed during setup' do
      game = fixture_at_action(495)

      # in https://github.com/tobymao/18xx/issues/9309,
      # ability_combo_entities threw an error instead of successfully
      # returning because P10 is removed in NRS setup
      entity = game.company_by_id('P12')
      expect(game.ability_combo_entities(entity)).to eq([])
    end
  end
end
