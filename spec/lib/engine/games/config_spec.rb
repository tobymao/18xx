# frozen_string_literal: true

require './spec/spec_helper'
require './lib/engine/config/tile'

require 'json'

module Engine
  include Engine::Config::Tile
  tile_colors = COLORS
  players = ('a'..'z')

  Engine::GAME_METAS.each do |game_meta|
    describe game_meta.title do
      let(:min_players) { players.take(game_meta::PLAYER_RANGE.min) }
      let(:max_players) { players.take(game_meta::PLAYER_RANGE.max) }

      it 'can be initialized with min players' do
        Engine.game_by_title(game_meta.title).new(min_players, id: 1)
      end

      it 'can be initialized with max players' do
        Engine.game_by_title(game_meta.title).new(max_players, id: 2)
      end

      it 'has consistent borders' do
        game = Engine.game_by_title(game_meta.title).new(max_players, id: 1)
        game.hexes.each do |hex|
          hex.tile.borders.each do |border|
            next unless border

            other_hex = hex.neighbors[border.edge]
            next if !other_hex && (border.type.nil? || border.type == :impassable || border.type == :divider)

            other_hex ||= game.hex_neighbor(hex, border.edge)

            expect(other_hex).to be_truthy,
                                 "Other hex missing from:#{hex.name}:#{border.edge}"
            other_border = other_hex.tile.borders.find { |b| b.edge == Hex.invert(border.edge) }
            expect(other_border).to be_truthy,
                                    "Other Hex missing border from:#{hex.name}:#{border.edge}"\
                                    " to other:#{other_hex.name}:#{Hex.invert(border.edge)}"
            expect(border.type).to eq(other_border.type),
                                   "Border types mismatch from:#{hex.name}:#{border.edge}"\
                                   " other:#{other_hex.name}:#{Hex.invert(border.edge)}"
            expect(border.color).to eq(other_border.color),
                                    "Border colors mismatch from:#{hex.name}:#{border.edge}"\
                                    " other:#{other_hex.name}:#{Hex.invert(border.edge)}"
            expect(border.cost).to eq(other_border.cost),
                                   "Border costs mismatch from:#{hex.name}:#{border.edge}"\
                                   " other:#{other_hex.name}:#{Hex.invert(border.edge)}"
          end
        end
      end

      it 'has no duplicates in HEXES' do
        hex_ids = Engine.game_by_title(game_meta.title)::HEXES.values.map(&:keys).flatten
        counts = hex_ids.each_with_object(Hash.new(0)) do |hex_id, memo|
          memo[hex_id] += 1
        end
        dups = counts.select { |_, count| count > 1 }.keys
        expect(dups).to eq([])
      end

      it 'tile colors are in COLORS' do
        game = Engine.game_by_title(game_meta.title).new(max_players, id: 1)
        game.tiles.each do |tile|
          expect(tile_colors).to include(tile.color), "Tile #{tile.id}"
        end
      end
    end
  end
end
