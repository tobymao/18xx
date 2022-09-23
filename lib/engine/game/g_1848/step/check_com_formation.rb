# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1848
      module Step
        class CheckCOMFormation < Engine::Step::Base
          ACTIONS = %w[destination_connection].freeze

          def actions(entity)
            return [] unless entity == current_entity

            @connected = false

            return [] if @game.sydney_adelaide_connected
            return ACTIONS if @game.loading
            return [] unless @game.check_for_sydney_adelaide_connection

            @connected = true
            ACTIONS
          end

          def description
            'COM Sydney Adelaide Check'
          end

          def blocks?
            @connected
          end

          def auto_actions(entity)
            return [] unless @connected

            [Engine::Action::DestinationConnection.new(entity)]
          end

          def process_destination_connection(_action)
            @game.log << 'Sydney and Adelaide are connected - COM may start operating' unless @game.com_can_operate
            @game.event_com_connected!
          end
        end
      end
    end
  end
end
