# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1858India::Game do
  describe 262_198 do
    it 'gauge conversion keeps the token in a city shared by two private reservations' do
      game = fixture_at_action(313, clear_cache: true)

      c8 = game.hex_by_id('C8')
      city = c8.tile.cities[0]

      expect(c8.tile.id).to eq('658-0')
      expect(city.tokens.compact.map { |token| token.corporation.id }).to eq(['SIR'])
      # ML's reservation is for the city's second slot, which only exists once
      # the city is upgraded to green.
      expect(city.reservations.map { |entity| entity&.id }).to eq([nil, 'ML'])

      msm = game.corporation_by_id('MSM')
      tile = game.tile_by_id('6-1')
      game.process_action(Engine::Action::LayTile.new(msm, hex: c8, tile: tile, rotation: 4))

      expect(game.exception).to be_nil
      expect(c8.tile.id).to eq('6-1')
      expect(c8.tile.cities[0].tokens.compact.map { |token| token.corporation.id }).to eq(['SIR'])
    end
  end
end
