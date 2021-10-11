# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1873
      module Step
        class Destinate < Engine::Step::Base
          ACTIONS = %w[destination_connection].freeze
          def auto_actions(entity)
            return [] unless @round.num_laid_track.positive?

            [
              Engine::Action::DestinationConnection.new(
                entity,
                minors: @game.minors.select { |m| @game.check_mine_connected?(m) }
              ),
            ]
          end

          def skip!
            pass!
          end

          def actions(_entity)
            return [] unless @round.num_laid_track.positive?

            ACTIONS
          end

          def process_destination_connection(action)
            action.minors.each { |m| @game.connect_mine!(m) }
            pass!
          end
        end
      end
    end
  end
end
