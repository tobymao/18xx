# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Token < Base
      attr_reader :hexes, :price, :teleport_price, :extra, :from_owner

      def setup(hexes:, price:, teleport_price: nil, extra: nil, from_owner: nil)
        @hexes = hexes
        @price = price
        @teleport_price = teleport_price
        @extra = extra || false
        @from_owner = from_owner || false
      end
    end
  end
end
