# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G2038
      module Step
        class Route < Engine::Step::Route
          # All non-empty hexes are clickable when building a spaceship route.
          def available_hex(entity, hex)
            return unless entity == current_entity
            return unless actions(entity).include?('run_routes')

            !hex.empty
          end

          # Called by the frontend's G2038 route selector when submitting routes.
          # The route carries hexes: [...] from the serialized action.
          # We explore any unexplored hexes first, then handle logging/pass! ourselves
          # rather than calling super, so that any revenue-calculation error during
          # logging cannot leave the step un-passed and block the dividend action.
          def process_run_routes(action)
            entity = action.entity
            @round.routes = action.routes
            @round.extra_revenue = action.extra_revenue

            # Explore any unexplored blue hexes in the route.
            explored = []
            action.routes.each do |route|
              route.hexes.each do |hex|
                next unless @game.mine_state[hex.id].nil? && hex.tile.color == :blue

                @game.explore_hex!(hex.id)
                explored << hex.id
              end
            end
            @game.explored_this_run = explored.to_set

            # Validate MP and connectivity server-side.
            action.routes.each do |route|
              @game.check_distance(route, nil)
              @game.check_connected(route, nil)
              @game.mark_mines_used!(route)
            end

            # Log each route. Use format_revenue_currency with a rescue so a bad
            # revenue calculation never prevents pass! from being reached.
            action.routes.each do |route|
              revenue_str =
                begin
                  @game.format_revenue_currency(route.revenue)
                rescue StandardError
                  '(error)'
                end
              path_str = @game.revenue_str(route)
              @log << "#{entity.name} runs a #{route.train.name} for #{revenue_str}: #{path_str}"
            end

            pass!
          ensure
            @game.explored_this_run = nil
          end

          private

          def warn_if_not_transshipment(route)
            # Not used in hex-route model; kept as no-op.
          end
        end
      end
    end
  end
end
