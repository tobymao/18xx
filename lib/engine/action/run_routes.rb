# frozen_string_literal: true

require_relative 'base'
require_relative '../route'

module Engine
  module Action
    class RunRoutes < Base
      attr_reader :routes

      def initialize(entity, routes:)
        @entity = entity
        @routes = routes

        @routes.each(&:lock!)
      end

      def self.h_to_args(h, game)
        routes = []

        h['routes'].each do |route|
          # hexes and revenue are for backwards compatability
          # they can be removed in the future
          override = nil

          if (hex_ids = route['hexes'])
            override = {
              hexes: hex_ids.map { |id| game.hex_by_id(id) },
              revenue: route['revenue'],
            }
          end

          connection_hexes = route['connections']

          routes << Route.new(
            game,
            game.phase,
            game.train_by_id(route['train']),
            connection_hexes: connection_hexes,
            override: override,
            routes: routes,
            halts: route['halts'],
          )
        end

        { routes: routes }
      end

      def args_to_h
        routes = @routes.map do |route|
          h = { 'train' => route.train.id }

          h['halts'] = route.halts if route.halts

          if route.connections.any?
            h['connections'] = route.connection_hexes
          else # legacy routes
            h['hexes'] = route.hexes.map(&:id)
            h['revenue'] = route.revenue
          end

          h
        end

        { 'routes' => routes }
      end
    end
  end
end
