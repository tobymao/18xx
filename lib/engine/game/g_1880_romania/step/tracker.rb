# frozen_string_literal: true

require_relative '../../../step/tracker'

module Engine
  module Game
    module G1880Romania
      module Tracker
        include Engine::Step::Tracker

        def remove_border_calculate_cost!(tile, entity_or_entities, spender)
          total_cost, border_types = super

          @game.remove_crossed_impassable_borders!(tile)

          [total_cost, border_types]
        end

        def can_ignore_borders?(entity)
          entity.owner == @game.consortiu&.owner
        end

        def hex_neighbors(entity, hex)
          connected_edges = Array(super)
          return connected_edges unless can_ignore_borders?(entity)

          hex.tile.borders.each do |border|
            next unless border.type == :impassable

            neighbor = hex.all_neighbors[border.edge]
            next unless neighbor

            inv_edge = Engine::Hex.invert(border.edge)
            next if neighbor.paths[inv_edge].empty?

            connected_edges |= [border.edge]
          end

          connected_edges
        end

        def hex_neighbor_exists?(entity, hex, edge)
          return super unless can_ignore_borders?(entity)

          return super if hex.tile.borders.none? { |b| b.edge == edge && b.type == :impassable }

          hex.all_neighbors[edge]
        end
      end
    end
  end
end
