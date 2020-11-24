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

      def help
        return super unless current_entity.receivership?

        "#{current_entity.name} is in receivership (it has no president). Most of its "\
        'actions are automated, but it must have a player manually run its trains. '\
        "Please enter the best route you see for #{current_entity.name}."
      end

      def process_run_routes(action)
        entity = action.entity
        @round.routes = action.routes
        trains = {}
        @round.routes.each do |route|
          train = route.train
          @game.game_error("Cannot run another corporation's train. refresh") if train.owner && train.owner != entity
          @game.game_error('Cannot run train twice') if trains[train]
          @game.game_error('Cannot run train that operated') if train.operated

          trains[train] = true
          @log.action! "runs a #{train.name} train for "\
            "#{@game.format_currency(route.revenue)}: #{@game.revenue_str(route)}"
        end
        pass!
      end

      def available_hex(entity, hex)
        @game.graph.reachable_hexes(entity)[hex]
      end

      def round_state
        {
          routes: [],
        }
      end
    end
  end
end
