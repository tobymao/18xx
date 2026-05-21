# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18ESP
      module Step
        class CheckDestinationConnection < Engine::Step::Base
          ACTIONS = %w[destination_connection].freeze

          def actions(entity)
            return [] if @game.replaying? && @game.legacy_destination_format?

            if @game.replaying?
              return [] unless entity&.corporation?
              return [] if entity.destination_connected?

              return ACTIONS
            end
            return [] unless @game.new_destination_connection?(entity)

            ACTIONS
          end

          def auto_actions(entity)
            return [] if @game.replaying?
            return [] unless @game.new_destination_connection?(entity)

            [Engine::Action::DestinationConnection.new(entity, corporations: [entity])]
          end

          def description
            'Check destination connection'
          end

          def pass!; end

          def log_skip(_entity); end

          def process_destination_connection(action)
            action.corporations.first.goal_reached!(:destination)
            @passed = true
          end
        end
      end
    end
  end
end
