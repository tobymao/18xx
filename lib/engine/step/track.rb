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
        tile_lay = get_tile_lay(current_entity)
        return 'Lay Track' unless tile_lay

        if tile_lay[:lay] && tile_lay[:upgrade]
          'Lay/Upgrade Track'
        elsif tile_lay[:lay]
          'Lay Track'
        else
          'Upgrade Track'
        end
      end

      def pass_description
        @acted ? 'Done (Track)' : 'Skip (Track)'
      end

      def process_lay_tile(action)
        lay_tile_action(action)
        pass! unless can_lay_tile?(action.entity)
      end

      def available_hex(entity_or_entities, hex)
        # entity_or_entities is an array when combining private company abilities
        entities = Array(entity_or_entities)
        entity, *_combo_entities = entities

        tracker_available_hex(entity, hex)
      end
    end
  end
end
