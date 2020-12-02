# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class TileLay < Base
      attr_reader :hexes, :tiles, :free, :discount, :special, :connect, :blocks, :reachable, :must_lay_together, :cost

      def setup(tiles:, hexes: nil, free: false, discount: nil, special: nil,
                connect: nil, blocks: nil, reachable: nil, must_lay_together: false, cost: 0)
        @hexes = hexes
        @tiles = tiles
        @free = free
        @discount = discount || 0
        @special = special.nil? ? true : special
        @connect = connect.nil? ? true : connect
        @blocks = blocks.nil? ? true : blocks
        @reachable = !!reachable
        @must_lay_together = must_lay_together
        @cost = cost
      end
    end
  end
end
