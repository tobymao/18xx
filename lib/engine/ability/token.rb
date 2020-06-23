# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Token < Base
      attr_reader :hexes, :price, :teleport_price

      def setup(hexes:, price:, teleport_price: nil)
        @hexes = hexes
        @price = price
        @teleport_price = teleport_price
      end
    end
  end
end
