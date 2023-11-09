# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18NY
      module Step
        class CheckNYCFormation < Engine::Step::Base
          ACTIONS = %w[destination_connection].freeze

          def actions(entity)
            return [] unless entity == current_entity

            ACTIONS
          end

          def auto_actions(entity)
            return [] if @game.nyc_formation_triggered? || !@game.albany_and_buffalo_connected?

            [Engine::Action::DestinationConnection.new(entity)]
          end

          def blocks?
            false
          end

          def process_destination_connection(_action)
            @game.log << 'Albany and Buffalo connected by track'
            @game.event_nyc_formation!
          end
        end
      end
    end
  end
end
