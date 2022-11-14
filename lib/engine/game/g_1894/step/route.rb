# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1894
      module Step
        class Route < Engine::Step::Route
          def process_run_routes(action)
            super
            return if @game.loading

            return unless route_includes_london?(action.routes) && !@game.ferry_marker?(action.entity)

            raise GameError, 'Cannot run to London without a ferry marker'
          end

          def route_includes_london?(routes)
            routes.flat_map(&:connection_hexes).include?(Engine::Game::G1894::Game::LONDON_HEX)
          end

          def available_hex(entity, hex)
            return @game.ferry_marker?(entity) if hex.id == Engine::Game::G1894::Game::LONDON_HEX

            super
          end
        end
      end
    end
  end
end
