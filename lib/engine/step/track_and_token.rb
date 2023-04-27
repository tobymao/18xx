# frozen_string_literal: true

require_relative 'tokener'
require_relative 'track'

module Engine
  module Step
    class TrackAndToken < Track
      include Tokener
      ACTIONS = %w[lay_tile place_token pass].freeze

      def actions(entity)
        actions = []
        return actions if entity != current_entity

        actions << 'lay_tile' if can_lay_tile?(entity)
        actions << 'place_token' if can_place_token?(entity)
        actions << 'pass' if actions.any?
        actions
      end

      def description
        'Place a Token or Lay Track'
      end

      def pass_description
        @acted ? 'Done (Token/Track)' : 'Skip (Token/Track)'
      end

      def setup
        super
        @tokened = false
      end

      def unpass!
        super
        setup
      end

      def can_place_token?(entity)
        super && !@tokened
      end

      def can_lay_tile?(entity)
        free = false

        @game.abilities(entity, :tile_lay) do |ability|
          ability.hexes.each do |hex_id|
            free = true if (ability.free || ability.discount >= @game.class::TILE_COST) &&
                           @game.hex_by_id(hex_id).tile.preprinted
          end
        end

        (free || buying_power(entity) >= @game.class::TILE_COST) && super
      end

      def process_place_token(action)
        entity = action.entity

        place_token(entity, action.city, action.token)
        @tokened = true
        pass! unless can_lay_tile?(entity)
      end

      def process_lay_tile(action)
        lay_tile_action(action)
        pass! if !can_lay_tile?(action.entity) && @tokened
      end

      def available_hex(entity, hex)
        return true if can_lay_tile?(entity) && tracker_available_hex(entity, hex)
        return true if can_place_token?(entity) && tokener_available_hex(entity, hex)

        false
      end
    end
  end
end
