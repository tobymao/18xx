# frozen_string_literal: true

require_relative '../route'

module Engine
  module Step
    module G1870
      class ConnectionRoute < Route
        def actions(entity)
          return [] unless entity.operator?

          ACTIONS
        end

        def active?
          @round.connection_runs.any?
        end

        def active_entities
          @round.connection_runs || []
        end

        def override_entities
          @round.connection_runs
        end

        def context_entities
          @round.entities
        end

        def active_context_entity
          @round.entities[@round.entity_index]
        end

        def process_run_routes(action)
          if (ability = action.corporation.abilities(:assign_hexes).first)
            home = action.corporation.tokens.first.city&.hex
            destination = @game.hexes.find { |h| h.name == ability.hexes.first }

            connection = action.routes.any? do |route|
              [home, destination].difference(route.visited_stops).none?
            end

            unless connection
              return @game.game_error('At least one train has to run from the home station to the destination')
            end
          end

          super
        end
      end
    end
  end
end
