# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class Message < Base
      ACTIONS = %w[log message].freeze

      def actions(entity)
        return [] unless entity.player?

        ACTIONS
      end

      def process_log(action)
        @log << action
      end

      def process_message(action)
        @log << action
      end

      def skip!; end

      def pass!; end

      def unpass!; end

      def blocks?
        @game.finished
      end
    end
  end
end
