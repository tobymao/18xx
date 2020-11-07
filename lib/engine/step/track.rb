# frozen_string_literal: true

require_relative 'base'
require_relative 'tracker'

module Engine
  module Step
    class Track < Base
      include Tracker
      ACTIONS = %w[lay_tile pass].freeze

      def actions(entity)
        return [] unless entity == current_entity
        return [] if entity.company? || !can_lay_tile?(entity)

        ACTIONS
      end

      def description
        'Lay Track'
      end

      def pass_description
        @acted ? 'Done (Track)' : 'Skip (Track)'
      end

      def process_lay_tile(action)
        lay_tile_action(action)
        pass! unless can_lay_tile?(action.entity)
      end

      def available_hex(entity, hex)
        @game.graph.connected_hexes(entity)[hex]
      end
    end
  end
end
