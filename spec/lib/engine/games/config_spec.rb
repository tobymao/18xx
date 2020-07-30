# frozen_string_literal: true

require './spec/spec_helper'

require 'engine'
require 'json'

module Engine
  Engine::GAMES.each do |title|
    describe title.title do
      it 'can be initialized' do
        players = %w[a b c]
        title.new(players, id: 1)
      end
    end

    describe title.title do
      it 'has consistent borders' do
        players = %w[a b c]
        game = title.new(players, id: 1)
        game.hexes.each do |hex|
          hex.tile.borders.each do |border|
            next unless border

            other_hex = hex.neighbors[border.edge]
            next if !other_hex && (border.type.nil? || border.type == :impassable)

            expect(other_hex).to be_truthy,
                                 "Other hex missing from:#{hex.name}:#{border.edge}"
            other_border = other_hex.tile.borders.find { |b| b.edge == Hex.invert(border.edge) }
            expect(other_border).to be_truthy,
                                    "Other Hex missing border from:#{hex.name}:#{border.edge}"\
                                    " to other:#{other_hex.name}:#{Hex.invert(border.edge)}"
            expect(border.type).to eq(other_border.type),
                                   "Border types mismatch from:#{hex.name}:#{border.edge}"\
                                   " other:#{other_hex.name}:#{Hex.invert(border.edge)}"
            expect(border.cost).to eq(other_border.cost),
                                   "Border costs mismatch from:#{hex.name}:#{border.edge}"\
                                   " other:#{other_hex.name}:#{Hex.invert(border.edge)}"
          end
        end
      end
    end
  end
end
