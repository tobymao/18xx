# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18ESP
      module Step
        class CheckDestinationConnection < Engine::Step::Base
          ACTIONS = %w[destination_connection].freeze

          def actions(entity)
            return [] unless entity == current_entity

            if @game.loading
              return [] unless entity&.corporation?
              return [] if entity.destination_connected?

              return ACTIONS
            end
            return [] unless @game.new_destination_connection?(entity)

            ACTIONS
          end

          def auto_actions(entity)
            return [] if @game.loading
            return [] unless @game.new_destination_connection?(entity)

            [Engine::Action::DestinationConnection.new(entity, corporations: [entity])]
          end

          def description
            'Check destination connection'
          end

          def blocking?
            return false if @game.loading

            super
          end

          def pass!; end

          def log_skip(_entity); end

          def process_destination_connection(action)
            corp = action.corporations.first
            corp.goal_reached!(:destination)
            @game.clear_graph_for_entity(corp)
            # Track may have been skipped by skip_steps because can_token? was
            # false while the token was still blocked.  Now that goal_reached!
            # released it, reactivate Track so place_token remains available.
            track_step = @round.steps.find { |s| s.is_a?(Engine::Game::G18ESP::Step::Track) }
            track_step&.reactivate_for_token!
            @passed = true
          end
        end
      end
    end
  end
end
