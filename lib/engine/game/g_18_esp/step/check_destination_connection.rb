# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18ESP
      module Step
        class CheckDestinationConnection < Engine::Step::Base
          ACTIONS = %w[destination_connection].freeze

          def actions(entity)
            return [] if @game.loading
            return [] unless new_destination_connection?(entity)

            ACTIONS
          end

          def auto_actions(entity)
            return [] if @game.loading
            return [] unless new_destination_connection?(entity)

            [Engine::Action::DestinationConnection.new(entity, corporations: [entity])]
          end

          def description
            'Check destination connection'
          end

          # Step is not player-passable; @passed is set in process_destination_connection
          def pass!; end

          def process_destination_connection(action)
            action.corporations.first.goal_reached!(:destination)
            @passed = true
          end

          private

          def new_destination_connection?(entity)
            entity&.corporation? &&
              !entity.destination_connected? &&
              @game.check_for_destination_connection(entity)
          end
        end
      end
    end
  end
end
