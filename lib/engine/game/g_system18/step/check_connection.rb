# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module GSystem18
      module Step
        class CheckConnection < Engine::Step::Base
          ACTIONS = %w[destination_connection].freeze
          def auto_actions(entity)
            corporations = if destination?(entity)
                             [entity]
                           else
                             []
                           end

            [Engine::Action::DestinationConnection.new(
              entity,
              corporations: corporations,
            )]
          end

          def destination?(corporation)
            return unless (destination = @game.destination_hex(corporation))
            return unless destination.assigned?(corporation)
            return unless corporation.tokens.first.city&.hex
            return if corporation.trains.empty?

            home_node = corporation.tokens.first.city
            max_nodes = corporation.trains.map(&:distance).max
            # destination.tile.nodes.first&.walk(corporation: corporation) do |path, _, visited|
            home_node.walk(corporation: corporation) do |path, _, visited|
              return true if path.nodes.map(&:hex).include?(destination) && visited.size < max_nodes
            end

            false
          end

          def round_state
            { connection_available: {} }
          end

          def setup
            @round.connection_available = {}
          end

          def description
            'Check for new connection runs'
          end

          def actions(_entity)
            ACTIONS
          end

          # This step should not be passed
          # This prevents the force_next_entity! from trying
          def pass!; end

          def process_destination_connection(action)
            action.corporations.each do |corporation|
              @game.log << "-- #{corporation.name} can connect to its destination --"

              @round.connection_available[corporation] = @game.destination_hex(corporation)
            end
            @passed = true
          end
        end
      end
    end
  end
end
