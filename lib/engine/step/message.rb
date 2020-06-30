# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class Message < Base
      ACTIONS = %w[message].freeze

      def actions(_entity)
        ACTIONS
      end

      def process_message(action)
        @log << action
      end

      def blocking?
        false
      end
    end
  end
end
