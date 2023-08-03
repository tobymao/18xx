# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1841
      module Step
        class Destinate < Engine::Step::Base
          ACTIONS = %w[destination_connection].freeze
          def auto_actions(entity)
            return [] unless @round.num_laid_track.positive?

            [
              Engine::Action::DestinationConnection.new(
                entity,
                hexes: @game.new_offboard_connections(entity),
              ),
            ]
          end

          def description
            raise GameError, 'Destinate is active'
          end

          def skip!
            pass!
          end

          def actions(_entity)
            return [] unless @round.num_laid_track.positive?

            ACTIONS
          end

          def process_destination_connection(action)
            @game.make_offboard_connection(action.hexes)
            pass!
          end
        end
      end
    end
  end
end
