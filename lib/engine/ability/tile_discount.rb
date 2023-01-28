# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class TileDiscount < Base
      attr_reader :terrain, :discount, :hexes

      def setup(discount:, terrain: nil, hexes: nil, exact_match: true)
        @discount = discount
        @terrain = terrain&.to_sym
        @hexes = hexes
        @exact_match = exact_match
      end

      def discounts_tile?(tile)
        (@exact_match && tile.terrain.uniq == [@terrain]) || (!@exact_match && tile.terrain.include?(@terrain))
      end
    end
  end
end
