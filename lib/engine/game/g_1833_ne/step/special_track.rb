# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1833NE
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          P3_TILES = {
            'C4' => %w[3 4 58],
            'C6' => %w[7 8 9],
          }.freeze

          def legal_tile_rotation?(entity, hex, tile)
            return false unless super
            return true unless p3_lay?(entity)
            return false unless p3_tile_allowed?(hex, tile)
            return true unless hex.id == 'C4'

            edge, = hex.neighbors.find { |_, neighbor| neighbor.id == 'B3' }
            return true unless edge

            tile.exits.include?(edge)
          end

          def potential_tiles(entity, hex)
            tiles = super
            return tiles unless p3_lay?(entity)

            tiles.select { |tile| P3_TILES[hex.id].include?(tile.name) }
          end

          private

          def p3_tile_allowed?(hex, tile)
            allowed = P3_TILES[hex.id]
            allowed.nil? || allowed.include?(tile.name)
          end

          def p3_lay?(entity)
            entity.respond_to?(:sym) && entity.sym == 'P3'
          end
        end
      end
    end
  end
end
