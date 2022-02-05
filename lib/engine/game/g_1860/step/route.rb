# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1860
      module Step
        class Route < Engine::Step::Base
          ACTIONS = %w[run_routes].freeze

          def actions(entity)
            check_insolvency!(entity)
            return [] if !entity.operator? ||
                         (entity.trains.empty? && !@game.insolvent?(entity)) ||
                         !@game.legal_route?(entity)

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
                @game.legal_route?(entity) && !can_afford_depot_train?(entity)
              @game.make_insolvent(entity)
            elsif @game.insolvent?(entity) && can_afford_depot_train?(entity)
              @game.clear_insolvent(entity)
            end
          end

          def can_afford_depot_train?(entity)
            min_price = @game.depot.min_depot_price
            min_price.positive? && entity.cash >= min_price
          end

          def train_name(_entity, train)
            if @game.nationalization
              short_train = train.name.split('+')[0]
              "#{short_train} (#{train.name})"
            else
              train.name
            end
          end

          def process_run_routes(action)
            entity = action.entity
            @round.routes = action.routes

            if @round.routes.empty? && @game.legal_route?(entity) && (entity.trains.any? || @game.insolvent?(entity)) &&
                (!entity.receivership? || !@game.nationalization)
              raise GameError, 'Must run a route'
            end

            trains = {}

            @round.routes.each do |route|
              train = route.train
              leased = ' '
              if train.owner && @game.train_owner(train) != entity
                raise GameError, "Cannot run another corporation's train. refresh"
              end
              raise GameError, 'Cannot run train twice' if trains[train]

              leased = ' (leased) ' if @game.insolvent?(entity)

              trains[train] = true
              @log << "#{entity.name} runs a #{train.name} train#{leased}for "\
                      "#{@game.format_currency(route.revenue)}: #{route.revenue_str}"
            end
            pass!
          end

          def conversion?
            false
          end

          def available_hex(_entity, _hex)
            true
          end

          def round_state
            {
              routes: [],
            }
          end

          def chart(entity)
            curr_price = entity.share_price.price
            [
              ['Revenue', 'Price Change'],
              [@game.format_currency(0), '1 ←'],
              ["≥ #{@game.format_currency(1)}", 'none'],
              ["≥ #{@game.format_currency(curr_price)}", '1 →'],
              ["≥ #{@game.format_currency(2 * curr_price)}", '2 →'],
              ["≥ #{@game.format_currency(3 * curr_price)}", '3 →'],
              ["≥ #{@game.format_currency(4 * curr_price)}", '4 →'],
            ]
          end
        end
      end
    end
  end
end
