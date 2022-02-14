# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1870
      module Step
        class CheckConnection < Engine::Step::Base
          ACTIONS = %w[destination_connection].freeze
          # Since *any* corporation could destinated after a given corporation does a tile lay, we need
          # to check for *all* corporations, and since multiple corporations could destinate at once
          # we need to be able to support multiple destinating at once
          # This also needs to be checked in the beginning of the OR, because it's possible for a
          # token to be removed during the SR if a corporation closes
          def auto_actions(entity)
            corporations = if @round.entity_index.zero? || @round.step_passed?(G1870::Step::CheckConnection)
                             @round.entities.select { |c| destination?(c) } # destinate in OR order
                           else
                             []
                           end

            # if the current corporation is also destinating, it must run first
            i = corporations.find_index(@round.current_operator)
            corporations = [@round.current_operator] + (corporations - [@round.current_operator]) if !i.nil? && i.positive?

            [Engine::Action::DestinationConnection.new(
              entity,
              corporations: corporations,
            )]
          end

          def destination?(corporation)
            return unless (destination = @game.destination_hex(corporation))
            return unless destination.assigned?(corporation)
            return unless (home = @game.home_hex(corporation))
            return if corporation.trains.empty?

            home_node = home.tile.cities.first # Each tile with a city has exactly one node
            max_nodes = corporation.trains.map(&:distance).max
            destination.tile.nodes.first&.walk(corporation: corporation) do |path, _, visited|
              return true if path.nodes.include?(home_node) && visited.size < max_nodes
            end

            false
          end

          def round_state
            { connection_runs: {} }
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

              @round.connection_runs[corporation] = @game.destination_hex(corporation)
            end
            @passed = true
          end
        end
      end
    end
  end
end
