# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1822MX::Game do
  describe 'fcm_cannot_lay_thru_mexico_city' do
    it 'O22 is not an available hex for FCM' do
      game = fixture_at_action(358)

      fcm = game.corporation_by_id('FCM')
      track_step = game.active_step

      expect(game.current_entity).to eq(fcm)
      expect(track_step.class).to eq(Engine::Game::G1822MX::Step::Track)

      expect(game).to have_available_hexes(%w[N23 N25])
    end
  end
end
