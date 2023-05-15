# frozen_string_literal: true

module Engine
  module Game
    module G1870
      module Step
        module Connection
          def override_entities
            @round.connection_runs.keys
          end

          def active_entities
            @round.connection_runs.keys.take(1)
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

          def active?
            !@round.connection_runs.empty? && !passed?
          end
        end
      end
    end
  end
end
