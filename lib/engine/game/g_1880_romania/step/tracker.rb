# frozen_string_literal: true

require_relative '../../../step/tracker'

module Engine
  module Game
    module G1880Romania
      module Tracker
        include Engine::Step::Tracker

        def can_ignore_borders?(entity)
          return false unless entity&.corporation?

          entity.owner == @game.p2&.owner
        end

        def legal_tile_rotation?(entity_or_entities, hex, tile)
          entity = Array(entity_or_entities).first

          # Normal corps use engine logic
          return super unless can_ignore_borders?(entity)

          old_ctedges = hex.tile.city_town_edges
          new_exits = tile.exits
          new_ctedges = tile.city_town_edges
          added_cities = [0, new_ctedges.size - old_ctedges.size].max
          multi_city_upgrade = tile.cities.size > 1 && hex.tile.cities.size > 1

          # Use all_neighbors instead of neighbors
          all_new_exits_valid = new_exits.all? { |edge| hex.all_neighbors[edge] }
          return false unless all_new_exits_valid

          # Still must connect to existing network
          neighbors = hex_neighbors(entity, hex) || []
          entity_reaches_a_new_exit = !(new_exits & neighbors).empty?
          return false unless entity_reaches_a_new_exit

          return false unless old_paths_maintained?(hex, tile)

          valid_added_city_count =
            added_cities >= new_ctedges.count do |newct|
              old_ctedges.all? { |oldct| (newct & oldct).none? }
            end
          return false unless valid_added_city_count

          old_cities_map_to_new =
            !multi_city_upgrade ||
            old_ctedges.all? { |oldct| new_ctedges.one? { |newct| (oldct & newct) == oldct } }
          return false unless old_cities_map_to_new

          return false unless city_sizes_maintained(hex, tile)

          true
        end
      end
    end
  end
end
