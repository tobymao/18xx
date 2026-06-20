# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G2038
      module Step
        class Route < Engine::Step::Route
          def available_hex(entity, hex)
            return unless entity == current_entity
            return unless actions(entity).include?('run_routes')

            !hex.empty
          end

          def process_run_routes(action)
            entity = action.entity
            # Standard Round::Operating handoff — Engine::Step::Dividend reads these
            # to calculate revenue and trigger ran_train company closures.
            @round.routes = action.routes
            @round.extra_revenue = action.extra_revenue

            action.routes.each do |route|
              route.hexes.each do |hex|
                # Only unexplored blue (space) hexes need explore_hex!
                next if @game.mine_state[hex.id] || hex.tile.color != :blue

                @game.explore_hex!(hex.id)
              end
            end

            action.routes.each do |route|
              @game.check_distance(route, nil)
              @game.check_connected(route, nil)
              @game.mark_mines_used!(route)
            end

            action.routes.each do |route|
              revenue = @game.format_revenue_currency(route.revenue)
              @log << "#{entity.name} runs a #{route.train.name} for #{revenue}: #{@game.revenue_str(route)}"
            end

            pass!
          end
        end
      end
    end
  end
end
