# frozen_string_literal: true

require_relative '../../../step/tracker'

module Engine
  module Game
    module G1894
      module Tracker
        include Engine::Step::Tracker

        def check_track_restrictions!(entity, old_tile, new_tile)
          return if @game.loading || !entity.operator?

          if @game.class::GREEN_CITY_TILES.include?(old_tile.name)
            graph = @game.graph_for_entity(entity)
            graph.clear
            new_tile.paths.each do |path|
              next unless graph.connected_paths(entity)[path]

              return true
            end

            raise GameError, 'Corporation cannot upgrade a green city it doesn\'t have access to'
          end

          super
        end

        def legal_tile_rotation?(entity, hex, tile)
          return super unless @game.class::BROWN_CITY_TILES.include?(tile.name)

          old_paths = hex.tile.paths
          old_exits = hex.tile.exits
          new_paths = tile.paths
          new_exits = tile.exits

          new_exits.all? { |edge| hex.neighbors[edge] } &&
            old_paths.all? { |path| new_paths.any? { |p| path <= p } } &&
            new_exits.sort == old_exits.sort
        end
      end
    end
  end
end
