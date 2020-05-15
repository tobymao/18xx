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
        routes = h['routes'].map do |r|
          hexes = r['hexes'].map { |id| game.hex_by_id(id) }
          Route.new(game.phase, game.train_by_id(r['train']), hexes: hexes)
        end
        [routes]
      end

      def args_to_h
        routes = @routes.map do |route|
          {
            'train' => route.train.id,
            'hexes' => route.hexes.map(&:id),
            'revenue' => route.revenue,
          }
        end

        { 'routes' => routes }
      end
    end
  end
end
