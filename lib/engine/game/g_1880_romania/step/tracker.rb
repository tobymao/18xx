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
          connected_edges = super
          return connected_edges unless can_ignore_borders?(entity)

          connected = @game.graph_for_entity(entity).connected_hexes(entity)

          borders = hex.tile.borders.select { |b| b.type == :impassable }

          extra_edges = borders.filter_map do |border|
            edge = border.edge
            border = hex.tile.borders.find { |b| b.edge == edge && b.type == :impassable }
            next unless border

            neighbor = hex.all_neighbors[edge]
            next unless neighbor

            # The neighbor must already be connected AND must have track pointing back at us
            inv_edge = Engine::Hex.invert(edge)
            next unless connected[neighbor]&.include?(inv_edge)

            edge
          end

          return connected_edges if extra_edges.empty?

          Array(connected_edges) | extra_edges
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
