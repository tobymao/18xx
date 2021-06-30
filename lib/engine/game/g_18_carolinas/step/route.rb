# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G18Carolinas
      module Step
        class Route < Engine::Step::Route
          def actions(entity)
            return [] if !entity.operator? || !@game.enough_power?(entity) || !@game.can_run_route?(entity)

            ACTIONS
          end

          def chart(entity)
            curr_price = entity.share_price.price
            [
              ['Revenue', 'Price Change'],
              ["< #{@game.format_currency(curr_price / 2)}", '1 ←'],
              ["≥ #{@game.format_currency(curr_price / 2)}", 'none'],
              ["≥ #{@game.format_currency(curr_price)}", '1 →'],
              ["≥ #{@game.format_currency(2 * curr_price)}", '2 →'],
              ["≥ #{@game.format_currency(3 * curr_price)}", '3 →'],
              ["≥ #{@game.format_currency(4 * curr_price)}", '4 →'],
            ]
          end

          def process_run_routes(action)
            @game.update_route_trains(action.entity, action.routes)

            super
          end

          def variable_trains?(_entity)
            true
          end

          def variable_distance?(_entity)
            true
          end

          def add_train(routes)
            @game.add_train(routes[0].corporation)
          end

          def remove_train(route)
            @game.delete_train(route)
          end

          def increase_train(route)
            @game.increase_train(route)
          end

          def decrease_train(route)
            @game.decrease_train(route)
          end
        end
      end
    end
  end
end
