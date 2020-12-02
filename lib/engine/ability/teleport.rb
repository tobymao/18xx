# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Teleport < Base
      attr_reader :hexes, :tiles, :cost, :free_tile_lay

      def setup(hexes:, tiles:, cost: nil, free_tile_lay: false)
        @hexes = hexes
        @tiles = tiles
        @cost = cost
        @free_tile_lay = free_tile_lay
      end
    end
  end
end
