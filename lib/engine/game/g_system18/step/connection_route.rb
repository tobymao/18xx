# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module GSystem18
      module Step
        class ConnectionRoute < Engine::Step::Route
          def actions(entity)
            return [] unless entity.corporation?
            return [] unless connectable?(entity)

            %w[run_routes pass]
          end

          def pass_description
            'Skip Destination Run'
          end

          def connectable?(entity)
            @round.connection_available[entity] && entity.tokens.size < 3
          end

          def round_state
            super.merge({ finished_destination: {} })
          end

          def setup
            super
            @round.finished_destination = {}
          end

          def description
            'Run Destination Route'
          end

          def process_run_routes(action)
            super
            @round.finished_destination[action.entity] = true
          end

          def process_pass(action)
            super
            @round.connection_available[action.entity] = false
          end
        end
      end
    end
  end
end
