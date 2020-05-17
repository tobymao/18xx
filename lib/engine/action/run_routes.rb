# frozen_string_literal: true

require_relative 'base'
require_relative '../route'

module Engine
  module Action
    class RunRoutes < Base
      attr_reader :routes

      def initialize(entity, routes)
        @entity = entity
        @routes = routes
      end

      def self.h_to_args(h, game)
        routes = h['routes'].map do |route|
          # hexes and revenue are for backwards compatability
          # they can be removed in the future
          override = nil

          if (hex_ids = route['hexes'])
            override = {
              hexes: hex_ids.map { |id| game.hex_by_id(id) },
              revenue: route['revenue'],
            }
          end

          connection_hexes = route['connections']&.map do |hex_ids|
            hex_ids.map { |id| game.hex_by_id(id) }
          end

          Route.new(
            game.phase,
            game.train_by_id(route['train']),
            connection_hexes: connection_hexes,
            override: override,
          )
        end

        [routes]
      end

      def args_to_h
        routes = @routes.map do |route|
          {
            'train' => route.train.id,
            'hexes' => route.hexes.map(&:id),
            'revenue' => route.revenue,
            'connections' => route.connections.map(&:id),
          }
        end

        { 'routes' => routes }
      end
    end
  end
end
