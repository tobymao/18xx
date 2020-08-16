# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Token < Base
      attr_reader :hexes, :price, :teleport_price, :extra, :city

      def setup(hexes:, price:, teleport_price: nil, extra: nil, city: nil)
        @hexes = hexes
        @price = price
        @teleport_price = teleport_price
        @extra = extra || false
        @city = city
      end

      def check_target(city)
        match_hex_id = @hexes.include?(city.hex.id)
        match_city = @city.nil? || city == city.tile.cities[@city]
        match_hex_id && match_city
      end
    end
  end
end
