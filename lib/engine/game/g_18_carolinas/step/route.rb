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

          def help
            return super unless current_entity.receivership?

            leasing = if @game.must_buy_power?(current_entity)
                        'It is leasing train power corresponding to a minimum sized train from the bank. '
                      else
                        ''
                      end

            "#{current_entity.name} is in receivership (it has no president). Most of its "\
              'actions are automated, but it must have a player manually run its trains. '\
              "#{leasing}Please enter the best route you see for #{current_entity.name}."
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
        end
      end
    end
  end
end
