# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class BuyToken < Base
      attr_reader :city, :slot, :price

      def initialize(entity, city:, slot:, price:)
        super(entity)
        @city = city
        @slot = slot
        @price = price
      end

      def self.h_to_args(h, game)
        {
          city: game.city_by_id(h['city']),
          slot: h['slot'],
          price: h['price'],
        }
      end

      def args_to_h
        {
          'city' => @city.id,
          'slot' => @slot,
          'price' => @price,
        }
      end
    end
  end
end
