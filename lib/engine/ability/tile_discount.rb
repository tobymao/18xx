# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class TileDiscount < Base
      attr_reader :terrain, :discount, :hexes

      def setup(discount:, terrain: nil, hexes: nil)
        @discount = discount
        @terrain = terrain&.to_sym
        @hexes = hexes
      end
    end
  end
end
