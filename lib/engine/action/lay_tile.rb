# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class LayTile < Base
      attr_reader :hex, :tile, :rotation, :combo_entities

      def initialize(entity, tile:, hex:, rotation:, combo_entities: [])
        super(entity)
        @hex = hex
        @tile = tile
        @rotation = rotation

        # other private companies that combined their ability with the main
        # entity for this action
        @combo_entities = combo_entities
      end

      def self.h_to_args(h, game)
        {
          tile: game.tile_by_id(h['tile']),
          hex: game.hex_by_id(h['hex']),
          rotation: h['rotation'],
          combo_entities: (h['combo_entities'] || []).map { |id| game.company_by_id(id) },
        }
      end

      def args_to_h
        {
          'hex' => @hex.id,
          'tile' => @tile.id,
          'rotation' => @rotation,
          'combo_entities' => @combo_entities.empty? ? nil : @combo_entities.map(&:id),
        }
      end
    end
  end
end
