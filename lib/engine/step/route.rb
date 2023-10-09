# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class Route < Base
      ACTIONS = %w[run_routes].freeze

      def actions(entity)
        return [] if !entity.operator? || @game.route_trains(entity).empty? || !@game.can_run_route?(entity)

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
        @round.extra_revenue = action.extra_revenue
        trains = {}
        abilities = []

        @round.routes.each do |route|
          train = route.train
          raise GameError, "Cannot run another corporation's train. refresh" if train.owner && @game.train_owner(train) != entity
          raise GameError, 'Cannot run train twice' if trains[train]
          raise GameError, 'Cannot run train that operated' if train.operated

          trains[train] = true
          revenue = @game.format_revenue_currency(route.revenue)
          @log << "#{entity.name} runs a #{train.name} train for #{revenue}: #{route.revenue_str}"
          abilities.concat(route.abilities) if route.abilities
        end
        log_extra_revenue(entity, action.extra_revenue)
        pass!

        abilities.uniq.each { |type| @game.abilities(action.entity, type, time: 'route')&.use! }
      end

      def log_extra_revenue(entity, extra_revenue)
        return unless extra_revenue&.nonzero?

        revenue_str = @game.format_revenue_currency(extra_revenue)
        @log << "#{entity.name} receives #{revenue_str} additional revenue"
      end

      def conversion?
        false
      end

      def available_hex(entity, hex)
        @game.graph_for_entity(entity).reachable_hexes(entity)[hex]
      end

      def round_state
        {
          routes: [],
        }
      end
    end
  end
end
