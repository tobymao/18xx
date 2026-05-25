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
          result = super
          return result unless can_ignore_borders?(entity)

          connected = @game.graph_for_entity(entity).connected_hexes(entity)

          extra_edges = (0..5).filter_map do |edge|
            border = hex.tile.borders.find { |b| b.edge == edge && b.type == :impassable }
            next unless border

            neighbor = hex.all_neighbors[edge]
            next unless neighbor

            # The neighbor must already be connected AND must have track pointing back at us
            inv_edge = Engine::Hex.invert(edge)
            next unless connected[neighbor]&.include?(inv_edge)

            edge
          end

          return result if extra_edges.empty?

          (Array(result) + extra_edges).uniq
        end

        def hex_neighbor_exists?(entity, hex, edge)
          return super unless can_ignore_borders?(entity)

          border = hex.tile.borders.find { |b| b.edge == edge && b.type == :impassable }
          border ? hex.all_neighbors[edge] : super
        end
      end
    end
  end
end
