# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Teleport < Base
      attr_reader :tiles, :cost, :free_tile_lay
      attr_accessor :hexes

      def setup(hexes:, tiles:, cost: nil, free_tile_lay: false)
        @hexes = hexes
        @tiles = tiles
        @cost = cost
        @free_tile_lay = free_tile_lay
        @when = %w[track] if @when.empty?
        @passive = false
      end
    end
  end
end
