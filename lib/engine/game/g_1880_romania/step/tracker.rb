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

        def hex_neighbor_exists?(entity, hex, edge)
          can_ignore_borders?(entity) ? hex.all_neighbors[edge] : super
        end
      end
    end
  end
end
