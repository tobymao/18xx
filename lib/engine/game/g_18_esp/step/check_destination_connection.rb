# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18ESP
      module Step
        class CheckDestinationConnection < Engine::Step::Base
          ACTIONS = %w[destination_connection].freeze

          def actions(_entity)
            ACTIONS
          end

          def auto_actions(entity)
            return [] unless entity&.corporation?

            connected = @game.check_for_destination_connection(entity) ? [entity] : []
            [Engine::Action::DestinationConnection.new(entity, corporations: connected)]
          end

          def description
            'Check destination connection'
          end

          # Overridden to be a no-op: prevents force_next_entity! from skipping
          # this step before it has had a chance to fire its auto_action.
          def pass!; end

          def process_destination_connection(action)
            action.corporations.each { |c| c.goal_reached!(:destination) }
            @passed = true
          end
        end
      end
    end
  end
end
