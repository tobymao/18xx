# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Token < Base
      attr_reader :hexes, :teleport_price, :extra, :from_owner, :discount, :city,
                  :neutral, :cheater, :special_only

      def setup(hexes:, price: nil, teleport_price: nil, extra: nil,
                from_owner: nil, discount: nil, city: nil, neutral: nil,
                cheater: nil, special_only: nil)
        @hexes = hexes
        @price = price
        @teleport_price = teleport_price
        @extra = extra || false
        @from_owner = from_owner || false
        @discount = discount
        @city = city
        @neutral = neutral || false
        @cheater = cheater || false
        @special_only = special_only || false
      end

      def price(token = nil)
        return @price if !token || !discount

        token.price - (token.price * discount)
      end
    end
  end
end
