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
          @round.connection_runs.any? && !passed?
        end

        def override_entities
          @round.connection_runs.keys
        end

        def current_entity
          @round.connection_runs.keys.first
        end

        def context_entities
          @round.entities
        end

        def active_context_entity
          @round.entities[@round.entity_index]
        end

        def process_run_routes(action)
          super

          @round.connection_steps << self
        end
      end
    end
  end
end
