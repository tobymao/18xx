# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Token < Base
      attr_reader :hexes, :teleport_price, :extra_action, :from_owner, :discount, :city,
                  :neutral, :cheater, :special_only, :extra_slot, :check_tokenable, :closed_when_used_up

      def setup(hexes:, price: nil, teleport_price: nil, extra_action: nil,
                from_owner: nil, discount: nil, city: nil, neutral: nil,
                cheater: nil, extra_slot: nil, special_only: nil, check_tokenable: nil,
                closed_when_used_up: nil)
        @hexes = hexes
        @price = price
        @teleport_price = teleport_price
        @extra_action = extra_action || false
        @from_owner = from_owner || false
        @discount = discount
        @city = city
        @neutral = neutral || false
        @cheater = cheater || false
        @extra_slot = extra_slot || false
        @special_only = special_only || false
        @check_tokenable = check_tokenable.nil? ? true : check_tokenable
        @closed_when_used_up = closed_when_used_up || false
      end

      def price(token = nil)
        return @price if !token || !discount

        token.price - (token.price * discount)
      end
    end
  end
end
