# frozen_string_literal: true

require_relative '../tracker'

module Engine
  module Step
    module G1822
      module Tracker
        include Step::Tracker

        def legal_tile_rotation?(entity, hex, tile)
          # We will remove a town from the white S tile, this meaning we will not follow the normal path upgrade rules
          if hex.name == @game.class::UPGRADABLE_S_HEX_NAME &&
            tile.name == @game.class::UPGRADABLE_S_YELLOW_CITY_TILE &&
            @game.class::UPGRADABLE_S_YELLOW_CITY_TILE_ROTATIONS.include?(tile.rotation)
            return true
          end

          super
        end

        def potential_tiles(entity, hex)
          colors = if entity.corporation? && entity.type == :minor &&
                      @game.phase.status.include?('minors_green_upgrade')
                     @game.class::MINOR_GREEN_UPGRADE
                   else
                     @game.phase.tiles
                   end
          @game.tiles
               .select { |tile| colors.include?(tile.color) }
               .uniq(&:name)
               .select { |t| @game.upgrades_to?(hex.tile, t) }
               .reject(&:blocks_lay)
        end

        def remove_border_calculate_cost!(tile, entity)
          hex = tile.hex
          types = []

          total_cost = tile.borders.dup.sum do |border|
            next 0 unless (cost = border.cost)

            edge = border.edge
            neighbor = hex.neighbors[edge]
            next 0 unless hex.targeting?(neighbor)

            if neighbor.targeting?(hex)
              tile.borders.delete(border)
              neighbor.tile.borders.map! { |nb| nb.edge == hex.invert(edge) ? nil : nb }.compact!
            end

            types << border.type
            cost - border_cost_discount(entity, border, hex)
          end
          [total_cost, types]
        end
      end
    end
  end
end
