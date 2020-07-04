# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class Route < Base
      ACTIONS = %w[run_routes].freeze

      def actions(entity)
        puts entity.runnable_trains
        return [] if entity.runnable_trains.empty? || !@game.graph.route?(entity)

        ACTIONS
      end

      def process_run_routes(action)
      end
    end
  end
end
