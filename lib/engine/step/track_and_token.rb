# frozen_string_literal: true

require_relative 'track'

module Engine
  module Step
    class TrackAndToken < Track
      include Tokener
      ACTIONS = %w[lay_tile place_token pass].freeze

      def actions(entity)
        actions = []
        actions << "lay_tile" if can_lay_tile?(entity)
        actions << "place_token" if can_place_token?(entity)
        actions << "pass" if actions.any?
        actions
      end

      def description
        'Place a Token or Lay Track'
      end

      def pass_description
        'Skip (Token/Track)'
      end

      def setup
        @tokened = false
        @laid_track = 0
      end

      def unpass!
        super
        setup
      end

      def sequential?
        true
      end

      def can_place_token?(entity)
        super && !@tokened
      end

      def can_lay_tile?(entity)
        free = false

        entity.abilities(:tile_lay) do |ability|
          ability.hexes.each do |hex_id|
            free = true if ability.free && @game.hex_by_id(hex_id).tile.preprinted
          end
        end

        (free || entity.cash >= @game.class::TILE_COST) && @laid_track < 2
      end

      def process_place_token(action)
        entity = action.entity

        place_token(entity, action.city, action.token)
        @tokened = true
        pass! if @laid_track
      end

      def process_lay_tile(action)
        if action.tile.color != :yellow
          raise GameError, 'Cannot upgrade twice' if @upgraded
        end

        lay_tile(action)

        if action.tile.color != :yellow
          @upgraded = true
        end

        @laid_track += 1
        pass! if @laid_track == 2 && @tokened
      end
    end
  end
end
