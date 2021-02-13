# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class Program < Base
      ACTIONS = %w[program_buy_shares program_disable].freeze

      def actions(entity)
        return [] unless entity.player?

        ACTIONS
      end

      def process_program_buy_shares(action)
        process_program_enable(action)
      end

      def process_program_enable(action)
        @log << "#{action.entity.name} enabling programmed action #{action.class.print_name}"
        @game.programmed_actions[action.entity] = action
      end

      def process_program_disable(action)
        # @todo: This should only log to the player
        @log << "#{action.entity.name} programming disabled due to '#{action.reason}'" if action.reason
        @game.programmed_actions.delete(action.entity)
      end

      def skip!; end

      def blocks?
        false
      end
    end
  end
end
