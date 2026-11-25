# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1822MX::Game do
  describe '1822MX_game_end_stock_market' do
    it 'trains owned by NdeM cannot be bought by other companies' do
      game = fixture_at_action(433)

      ndem = game.ndem
      train = ndem.trains.first

      expect(train).not_to be_nil
      expect(game.active_step.buyable_trains(game.current_entity)).not_to include(train)
    end
  end

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
