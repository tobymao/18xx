# frozen_string_literal: true

require 'engine/action/base'
require 'engine/route'

module Engine
  module Action
    class RunRoutes < Base
      attr_reader :routes

      def initialize(entity, routes)
        @entity = entity
        @routes = routes
      end

      def self.h_to_args(h, game)
        route = Route.new(h['phase'], game.train_by_id(h['train']))
        h['hexes'].each { |id| route.add_hex(game.hex_by_id(id)) }
        [route]
      end

      def args_to_h
        routes = @routes.map do |route|
          {
            'phase': route.phase,
            'train': route.train.id,
            'hexes': route.hexes.map(&:id),
          }
        end

        {
          'entity' => @hex.id,
          'routes' => routes,
        }
      end
    end
  end
end
