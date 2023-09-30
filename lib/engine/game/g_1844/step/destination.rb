# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1844
      module Step
        class Destination < Engine::Step::Base
          ACTIONS = %w[destination_connection].freeze

          def actions(entity)
            return [] unless entity == current_entity

            ACTIONS
          end

          def auto_actions(entity)
            destinated = @game.corporations.select { |c| @game.destinated?(c) }
            return [] if destinated.empty?

            [Engine::Action::DestinationConnection.new(entity, corporations: destinated)]
          end

          def blocks?
            false
          end

          def process_destination_connection(action)
            action.corporations.each { |c| @game.destinated!(c) }
          end
        end
      end
    end
  end
end
