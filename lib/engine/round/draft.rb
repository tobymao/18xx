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
    end
  end
end
