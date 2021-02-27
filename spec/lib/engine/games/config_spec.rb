# frozen_string_literal: true

require './spec/spec_helper'

require 'json'

module Engine
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
