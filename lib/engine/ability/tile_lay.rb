# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class TileLay < Base
      attr_reader :hexes, :tiles, :free, :discount, :special, :connect, :blocks, :reachable

      def setup(tiles:, hexes: nil, free: false, discount: nil, special: nil,
                connect: nil, blocks: nil, reachable: nil)
        @hexes = hexes
        @tiles = tiles
        @free = free
        @discount = discount || 0
        @special = special.nil? ? true : special
        @connect = connect.nil? ? true : connect
        @blocks = blocks.nil? ? true : blocks
        @reachable = !!reachable
      end
    end
  end
end
