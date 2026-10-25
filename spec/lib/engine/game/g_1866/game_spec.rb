# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1866::Game do
  describe 268_711 do
    it 'does not let a national run through a hex outside its region' do
      game = fixture_at_action(917)
      de = game.corporation_by_id('DE')
      route = Engine::Route.new(
        game,
        game.phase,
        de.trains.first,
        routes: [],
        connection_hexes: [%w[E17 E15], %w[E15 F14 G15], %w[G15 H16 H18 G19]],
      )

      expect { route.revenue }.to raise_error(Engine::GameError, 'Nationals can only run within its region')
    end
  end
end
