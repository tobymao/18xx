# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1862
      module Step
        class Route < Engine::Step::Route
          def actions(entity)
            return [] if @game.skip_round[entity]

            super
          end

          def log_skip(entity)
            super unless @game.skip_round[entity]
          end

          def help
            return super unless current_entity.receivership?

            "#{current_entity.name} is in receivership (it has no president). Most of its "\
              "actions are automated, but the majority share owner (#{@game.acting_for_entity(current_entity).name}) "\
              "must manually run its trains. Please enter the best route you see for #{current_entity.name}."
          end

          def process_run_routes(action)
            super

            entity = action.entity
            @round.routes.each do |route|
              subsidy = route.subsidy
              if subsidy.positive?
                @log << "#{entity.name} runs a #{route.train.name} train for a subsidy of "\
                        "#{@game.format_currency(subsidy)}"
              end
            end
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
