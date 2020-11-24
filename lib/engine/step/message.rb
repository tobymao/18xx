# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class Message < Base
      ACTIONS = %w[message].freeze

      def actions(entity)
        return [] unless entity.player?

        ACTIONS
      end

      def process_message(action)
        @log.message! action
      end

      def skip!; end

      def blocks?
        @game.finished
      end
    end
  end
end
