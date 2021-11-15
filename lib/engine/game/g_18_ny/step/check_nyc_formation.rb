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
            return [] if @game.nyc_formation
            return ACTIONS if @game.loading
            return [] unless @game.albany_and_buffalo_connected?

            @connected = true
            ACTIONS
          end

          def blocks?
            @connected
          end

          def auto_actions(_entity)
            return [] unless @connected

            [Engine::Action::DestinationConnection(@game.nyc_corporation)]
          end

          def process_destination_connection(_action)
            raise GameError, 'Buffalo and Albany not connected' unless @game.albany_and_buffalo_connected?

            @game.log << 'Albany and Buffalo connected by track'
            @game.event_nyc_formation!
            @connected = nil
          end
        end
      end
    end
  end
end
