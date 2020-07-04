# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class TileDiscount < Base
      attr_reader :terrain, :discount
      def setup(terrain:, discount:)
        @terrain = terrain.to_sym
        @discount = discount
      end
    end
  end
end
