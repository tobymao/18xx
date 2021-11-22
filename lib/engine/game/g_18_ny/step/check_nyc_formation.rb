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

            @connected = false
            return [] if @game.nyc_formation_triggered?
            return ACTIONS if @game.loading
            return [] unless @game.albany_and_buffalo_connected?

            @connected = true
            ACTIONS
          end

          def description
            'NYC Formation Check'
          end

          def blocks?
            @connected
          end

          def auto_actions(entity)
            return [] unless @connected

            [Engine::Action::DestinationConnection.new(entity)]
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
