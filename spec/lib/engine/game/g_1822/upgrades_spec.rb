# frozen_string_literal: true

require 'spec_helper'

describe '1822 family town removal' do
  {
    Engine::Game::G1822::Game => %w[P2],
    Engine::Game::G1822PNW::Game => %w[P7 P8],
    Engine::Game::G1822MX::Game => %w[P12 P13],
    Engine::Game::G1822Africa::Game => %w[P9],
    Engine::Game::G1822CA::Game => %w[P29 P30],
  }.each do |game_class, company_ids|
    describe game_class do
      let(:game) do
        game_class.new(Array.new(game_class::PLAYER_RANGE.max) { |i| "Player #{i + 1}" })
      end
      let(:town_tile) { hex_tile('3', 'A1') }
      let(:plain_tile) { hex_tile('80', 'A2') }

      def hex_tile(name, hex_name)
        tile = game.tiles.find { |t| t.name == name }
        Engine::Hex.new(hex_name, layout: game.layout, tile: tile).tile
      end

      it 'does not offer plain track as a normal upgrade for a town tile' do
        upgrades = game.send(:all_potential_upgrades, town_tile, tile_manifest: true).map(&:name)

        expect(upgrades).to include('141')
        expect(upgrades).not_to include('80')
      end

      it 'still lets the remove-town company lay plain track' do
        company_ids.each do |id|
          ability = game.companies.find { |c| c.id == id }.all_abilities.find { |a| a.type == :tile_lay }

          expect(ability.special).to be(true)
          expect(game.upgrades_to?(town_tile, plain_tile, ability.special)).to be(true)
        end
      end
    end
  end
end
