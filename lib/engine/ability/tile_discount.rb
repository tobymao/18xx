# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class TileDiscount < Base
      attr_reader :terrain, :discount, :hexes
      def setup(terrain:, discount:, hexes: nil)
        @terrain = terrain.to_sym
        @discount = discount
        @hexes = hexes
      end
    end
  end
end
