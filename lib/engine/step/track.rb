# frozen_string_literal: true

require_relative 'base'
require_relative 'tracker'
module Engine
  module Step
    class Track < Base
      include Tracker
      ACTIONS = %w[lay_tile pass].freeze

      def actions(entity)
        entity == current_entity ? ACTIONS : []
      end

      def description
        'Lay Track'
      end

      def pass_description
        'Skip (Track)'
      end

      def sequential?
        true
      end

      def process_lay_tile(action)
        lay_tile(action)
        pass!
      end

      def available_hex(hex)
        @game.graph.connected_hexes(current_entity)[hex]
      end
    end
  end
end
