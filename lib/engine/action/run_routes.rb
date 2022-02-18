# frozen_string_literal: true

require_relative 'base'
require_relative '../route'

module Engine
  module Action
    class RunRoutes < Base
      attr_reader :routes

      def initialize(entity, routes:)
        super(entity)
        @routes = routes
      end

      def self.h_to_args(h, game)
        routes = []

        h['routes'].each do |route|
          opts = {
            connection_hexes: route['connections'],
            hexes: route['hexes']&.map { |id| game.hex_by_id(id) },
            revenue: route['revenue'],
            revenue_str: route['revenue_str'],
            subsidy: route['subsidy'],
            halts: route['halts'],
            abilities: route['abilities'],
            nodes: route['nodes'],
          }.select { |_, v| v }

          routes << Route.new(
            game,
            game.phase,
            game.train_by_id(route['train']),
            routes: routes,
            **opts,
          )
        end

        { routes: routes }
      end

      def args_to_h
        routes = @routes.map do |route|
          {
            'train' => route.train.id,
            'connections' => route.connection_hexes,
            'hexes' => route.hexes.map(&:id),
            'revenue' => route.revenue,
            'revenue_str' => route.revenue_str,
            'subsidy' => route.subsidy,
            'halts' => route.halts,
            'abilities' => route.abilities,
            'nodes' => route.nodes.map(&:signature),
          }.select { |_, v| v }
        end

        { 'routes' => routes }
      end
    end
  end
end
