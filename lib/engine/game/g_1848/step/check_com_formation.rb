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
            return [] if @game.sydney_adelaide_connected
            return ACTIONS if @game.loading
            return [] unless @game.check_for_sydney_adelaide_connection

            ACTIONS
          end

          def description
            'COM Sydney Adelaide Check'
          end

          def active?
            !@game.sydney_adelaide_connected
          end

          def blocks?
            @game.check_for_sydney_adelaide_connection
          end

          def auto_actions(entity)
            return [] unless @game.check_for_sydney_adelaide_connection

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
