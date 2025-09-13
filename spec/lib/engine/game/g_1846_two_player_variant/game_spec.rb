# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1846TwoPlayerVariant::Game do
  describe 11_098 do
    it 'has both reservations at the start of the game' do
      game = fixture_at_action(0)

      city = game.hex_by_id('D20').tile.cities.first
      erie = game.corporation_by_id('ERIE')
      nyc = game.corporation_by_id('NYC')

      expect(city.reservations).to eq([nyc, erie])
    end

    it 'keeps the second slot reserved for ERIE when NYC floats' do
      game = fixture_at_action(11)

      city = game.hex_by_id('D20').tile.cities.first
      erie = game.corporation_by_id('ERIE')
      nyc = game.corporation_by_id('NYC')

      expect(city.reservations).to eq([nil, erie])
      expect(city.tokens.map { |t| t&.corporation }).to eq([nyc, nil])
    end

    it "ERIE's token does not replace NYC's when ERIE uses its reserved spot" do
      game = fixture_at_action(24)

      city = game.hex_by_id('D20').tile.cities.first
      erie = game.corporation_by_id('ERIE')
      nyc = game.corporation_by_id('NYC')

      expect(city.reservations).to eq([nil, nil])
      expect(city.tokens.map { |t| t&.corporation }).to eq([nyc, erie])
    end
  end
end
