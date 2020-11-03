# frozen_string_literal: true

require_relative '../route'

module Engine
  module Step
    module G1828
      class Route < Route
        def process_run_routes(action)
          @game.buy_coal_marker(action.entity) if @game.can_buy_coal_marker?(action.entity)

          if route_includes_coalfields?(action.routes) && !@game.coal_marker?(action.entity)
            @game.game_error('Cannot run to Virginia Coalfields without a Coal Marker')
          else
            super
          end
        end

        def route_includes_coalfields?(routes)
          routes.flat_map(&:connection_hexes).flatten.include?(Engine::Game::G1828::VA_COALFIELDS_HEX)
        end
      end
    end
  end
end
