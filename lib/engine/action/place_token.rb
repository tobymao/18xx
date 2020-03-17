# frozen_string_literal: true

require 'engine/action/base'

module Engine
  module Action
    class PlaceToken < Base
      attr_reader :hex, :city, :slot

      def initialize(entity, hex, city, slot)
        @entity = entity
        @hex = hex
        @city = city
        @slot = slot
      end

      def self.h_to_args(h, game)
        [game.hex_by_id(h['hex']), game.share_price_by_id(h['share_price'])] # TODO
      end

      def args_to_h
        # TODO
        {
          'hex' => @hex.id,
          'city' => @city.id,
          'slot' => @slot.id,
        }
      end
    end
  end
end
