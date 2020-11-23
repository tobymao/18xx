# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G1860
      class Route < Base
        ACTIONS = %w[run_routes].freeze

        def actions(entity)
          # FIXME: deal with insolvency
          return [] if !entity.operator? || entity.runnable_trains.empty? || !@game.can_run_route?(entity)

          ACTIONS
        end

        def description
          'Run Routes'
        end

        def help
          # FIXME: deal with insolvency
          # FIXME: deal with receivership
          return super unless current_entity.receivership?

          "#{current_entity.name} is in receivership (it has no president). Most of its "\
            'actions are automated, but it must have a player manually run its trains. '\
            "Please enter the best route you see for #{current_entity.name}."
        end

        def process_run_routes(action)
          entity = action.entity
          @round.routes = action.routes
          # the following two checks must be made here, after all routes have been defined
          if @round.routes.reject { |r| r.connections.empty? }.any?
            @game.check_home_token(entity, @round.routes)
            @game.check_intersection(@round.routes)
          end
          trains = {}
          @round.routes.each do |route|
            train = route.train
            @game.game_error("Cannot run another corporation's train. refresh") if train.owner && train.owner != entity
            @game.game_error('Cannot run train twice') if trains[train]
            @game.game_error('Cannot run train that operated') if train.operated

            trains[train] = true
            @log << "#{entity.name} runs a #{train.name} train for "\
              "#{@game.format_currency(route.revenue)}: #{@game.revenue_str(route)}"
          end
          pass!
        end

        def available_hex(_entity, _hex)
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
end
