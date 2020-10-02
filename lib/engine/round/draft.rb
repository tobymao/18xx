# frozen_string_literal: true

require_relative 'base'

module Engine
  module Round
    class Draft < Base
      def name
        'Draft Round'
      end

      def select_entities
        @game.players.reverse
      end

      # def finished?
      #   @game.finished || @entities.all?(&:passed?) || @game.companies.all?(&:owned_by_player?)
      # end

      def setup
        @steps.each(&:unpass!)
        @steps.each(&:setup)
      end
    end
  end
end
