# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1850
      module Step
        class CheckConnection < Engine::Step::Base
          ACTIONS = %w[destination_connection].freeze
          # Since *any* corporation could destinated after a given corporation does a tile lay, we need
          # to check for *all* corporations, and since multiple corporations could destinate at once
          # we need to be able to support multiple destinating at once
          # This also needs to be checked in the beginning of the OR, because it's possible for a
          # token to be removed during the SR if a corporation closes
          def auto_actions(entity)
            corporations = if @round.entity_index.zero? || @round.step_passed?(G1850::Step::CheckConnection)
                             @game.corporations.select { |c| destination(c) }
                           else
                             []
                           end

            [Engine::Action::DestinationConnection.new(
              entity,
              corporations: corporations,
            )]
          end

          def destination(corporation)
            return unless (destination = @game.destination_hex(corporation))
            return unless destination.assigned?(corporation)
            return unless (home = @game.home_hex(corporation))

            destination.tile.nodes.first&.walk(corporation: corporation) do |path|
              return true if path.hex.id == home.id
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

          def process_destination_connection(action)
            action.corporations.each do |corporation|
              @game.log << "-- #{corporation.name} can connect to its destination --"

              @round.connection_runs[corporation] = @game.destination_hex(corporation)
            end
            pass!
          end
        end
      end
    end
  end
end
