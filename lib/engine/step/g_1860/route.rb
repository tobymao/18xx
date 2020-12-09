# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G1860
      class Route < Base
        ACTIONS = %w[run_routes].freeze

        def actions(entity)
          check_insolvency!(entity)
          return [] if !entity.operator? ||
                       entity.trains.empty? && !@game.insolvent?(entity) ||
                       !@game.can_run_route?(entity)

          ACTIONS
        end

        def description
          'Run Routes'
        end

        def help
          return super if !current_entity.receivership? && !@game.insolvent?(current_entity)

          text = ''
          if current_entity.receivership?
            text += "#{current_entity.name} is in receivership (it has no president). "\
              'Most of its actions are automated, but it must have a player manually run '\
              "its trains. Please enter the best route you see for #{current_entity.name}."
          end
          text += ' In addition, ' if current_entity.receivership? && @game.insolvent?(current_entity)
          if @game.insolvent?(current_entity)
            text += "#{current_entity.name} is insolvent. It is running a train leased from "\
              'the bank'
          end
          text
        end

        def check_insolvency!(entity)
          return unless entity.corporation?

          if entity.receivership? && entity.trains.empty? &&
              @game.can_run_route?(entity) && !can_afford_depot_train?(entity)
            @game.make_insolvent(entity)
          elsif @game.insolvent?(entity) && can_afford_depot_train?(entity)
            @game.clear_insolvent(entity)
          end
        end

        def can_afford_depot_train?(entity)
          min_price = @game.depot.min_depot_price
          min_price.positive? && entity.cash >= min_price
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
            if train.owner && @game.train_owner(train) != entity
              @game.game_error("Cannot run another corporation's train. refresh")
            end
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
