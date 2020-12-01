# frozen_string_literal: true

require_relative 'base'

module Engine
  module Round
    class Auction < Base
      def name
        'Auction Round'
      end

      def self.short_name
        'ISR'
      end

      def select_entities
        @game.players
      end
    end
  end
end
