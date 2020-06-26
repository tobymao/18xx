# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Token < Base
      attr_reader :hexes, :price, :teleport_price, :extra

      def setup(hexes:, price:, teleport_price: nil, extra: nil)
        @hexes = hexes
        @price = price
        @teleport_price = teleport_price
        @extra = extra || false
      end
    end
  end
end
