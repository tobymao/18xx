# frozen_string_literal: true

require 'engine/action/lay_tile'

module Engine
  module Round
    class Operating < Base
      attr_reader :num

      def initialize(entities, tiles:, num: 1)
        super
        @num = num
        @tiles = tiles
      end

      def finished?
        false
      end

      private

      def _process_action(action)
        case action
        when Action::LayTile
          @tiles.reject! { |t| action.tile.equal?(t) }
          action.hex.lay(action.tile)
        when Action::PlaceToken
          action.city.place_token(action.entity, action.slot)
        end
      end
    end
  end
end
