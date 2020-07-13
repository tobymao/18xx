# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class Route < Base
      ACTIONS = %w[run_routes].freeze

      def actions(entity)
        return [] if !entity.operator? || entity.runnable_trains.empty? || !@game.can_run_route?(entity)

        ACTIONS
      end

      def description
        'Run Routes'
      end

      def process_run_routes(action)
        entity = action.entity
        @round.routes = action.routes
        trains = {}
        @round.routes.each do |route|
          train = route.train
          raise GameError, "Cannot run another corporation's train. refresh" if train.owner && train.owner != entity
          raise GameError, 'Cannot run train twice' if trains[train]
          raise GameError, 'Cannot run train that operated' if train.operated

          trains[train] = true
          hexes = route.hexes.map(&:name).join(', ')
          @log << "#{entity.name} runs a #{train.name} train for "\
            "#{@game.format_currency(route.revenue)} (#{hexes})"
        end
        pass!
      end

      def available_hex(hex)
        @game.graph.reachable_hexes(current_entity)[hex]
      end

      def sequential?
        true
      end

      def round_state
        {
          routes: [],
        }
      end
    end
  end
end
