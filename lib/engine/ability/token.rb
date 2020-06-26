# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Token < Base
      attr_reader :hexes, :price, :teleport_price, :extra_token

      def setup(hexes:, price:, teleport_price: nil, extra_token: false)
        @hexes = hexes
        @price = price
        @teleport_price = teleport_price
        @extra_token = extra_token
      end
    end
  end
end
