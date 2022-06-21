# frozen_string_literal: true

require_relative '../../../step/tracker'

module Engine
  module Game
    module G1894
      module Tracker
        include Engine::Step::Tracker

        def check_track_restrictions!(entity, old_tile, new_tile)
          return if @game.loading || !entity.operator?
          return if @game.class::BROWN_CITY_TILES.include?(new_tile.name)

          super
        end

        def legal_tile_rotation?(_entity, hex, tile)
          if @game.class::BROWN_CITY_TILES.include?(tile.name)
            old_paths = hex.tile.paths    
            new_paths = tile.paths
            new_exits = tile.exits
    
            new_exits.all? { |edge| hex.neighbors[edge] } &&
              old_paths.all? { |path| new_paths.any? { |p| path <= p } }
          else
            super
          end
        end
      end
    end
  end
end
