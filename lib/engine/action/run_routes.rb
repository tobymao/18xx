# frozen_string_literal: true

require 'engine/action/base'
require 'engine/route'

module Engine
  module Action
    class RunRoutes < Base
      attr_reader :entity, :routes

      def initialize(entity, routes)
        @entity = entity
        @routes = routes
      end

      def copy(game)
        routes = @routes.map do |route|
          new_route = Route.new(route.phase, game.train_by_id(route.train))
          route.hexes.each do |hex|
            new_route.add_hex(hex)
          end
          new_route
        end

        self.class.new(
          game.corportation_by_name(@entity.name),
          routes,
        )
      end
    end
  end
end
