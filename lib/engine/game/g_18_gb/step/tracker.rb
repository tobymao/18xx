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
      end
    end
  end
end
