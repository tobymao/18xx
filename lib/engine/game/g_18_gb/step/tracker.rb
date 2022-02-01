# frozen_string_literal: true

require_relative '../../../step/tracker'

module Engine
  module Game
    module G18GB
      module Tracker
        include Engine::Step::Tracker

        def setup
          @laid_city = false
          super
        end

        def lay_tile_action(action)
          tile = action.tile
          tile_lay = get_tile_lay(action.entity)
          raise GameError, 'Cannot lay a city tile now' if tile.cities.any? && @laid_city

          lay_tile(action, extra_cost: tile_lay[:cost])
          @laid_city = true if action.tile.cities.any?
          @round.num_laid_track += 1
          @round.laid_hexes << action.hex
        end

        def remove_border_calculate_cost!(tile, entity, spender)
          hex = tile.hex
          types = []
          total_cost = tile.borders.dup.sum do |border|
            next 0 unless (cost = border.cost)

            edge = border.edge
            neighbor = hex.neighbors[edge]
            next 0 unless hex.targeting?(neighbor)

            tile.borders.delete(border)
            types << border.type
            cost - border_cost_discount(entity, spender, cost, hex)
          end

          [total_cost, types]
        end
      end
    end
  end
end
