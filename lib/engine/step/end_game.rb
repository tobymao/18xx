# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class EndGame < Base
      ACTIONS = %w[end_game].freeze

      def actions(_entity)
        ACTIONS
      end

      def active_entities
        entities
      end

      def process_end_game(_action)
        @game.end_game!
      end

      def blocking?
        false
      end
    end
  end
end
