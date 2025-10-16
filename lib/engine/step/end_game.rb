# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class EndGame < Base
      ACTIONS = %w[end_game].freeze

      def actions(entity)
        return [] if entity.company?

        ACTIONS
      end

      def process_end_game(action)
        @log << "Game ended manually by #{action.entity.name}"
        @game.end_game!(:manually_ended)
      end

      def blocks?
        false
      end
    end
  end
end
