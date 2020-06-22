# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Token < Base
      attr_reader :hexes, :free, :price, :teleport_price

      def setup(hexes:, free: nil, price:, teleport_price: nil)
        @hexes = hexes
        @free = free || false
        @price = price
        @teleport_price = teleport_price
      end
    end
  end
end
