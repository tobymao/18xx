# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Token < Base
      attr_reader :hexes, :teleport_price, :extra, :from_owner, :discount, :city,
                  :neutral

      def setup(hexes:, price: nil, teleport_price: nil, extra: nil,
                from_owner: nil, discount: nil, city: nil, neutral: nil)
        @hexes = hexes
        @price = price
        @teleport_price = teleport_price
        @extra = extra || false
        @from_owner = from_owner || false
        @discount = discount
        @city = city
        @neutral = neutral || false
      end

      def price(token = nil)
        return @price if !token || !discount

        token.price - (token.price * discount)
      end
    end
  end
end
