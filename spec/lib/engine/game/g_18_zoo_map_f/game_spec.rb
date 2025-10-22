# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G18ZOOMapF::Game do
  describe 6535 do
    it '"on a diet" cannot be executed automatically' do
      game = fixture_at_action(255, clear_cache: true)

      action = {
        'type' => 'place_token',
        'entity' => 'BB',
        'entity_type' => 'corporation',
        'city' => '5-1-0',
        'slot' => 1,
        'tokener' => 'BB',
      }
      expect(game.exception).to be_nil
      expect(game.process_action(action).exception).to be_a(Engine::GameError)
    end
  end
end
