# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class TileLay < Base
      attr_reader :tiles, :free, :discount, :special, :connect, :blocks,
                  :reachable, :must_lay_together, :cost, :must_lay_all, :closed_when_used_up,
                  :consume_tile_lay, :laid_hexes
      attr_accessor :hexes

      def setup(tiles:, hexes: nil, free: false, discount: nil, special: nil,
                connect: nil, blocks: nil, reachable: nil, must_lay_together: nil, cost: 0,
                closed_when_used_up: nil, must_lay_all: nil, consume_tile_lay: nil)
        @hexes = hexes
        @tiles = tiles
        @free = free
        @discount = discount || 0
        @special = special.nil? ? true : special
        @connect = connect.nil? ? true : connect
        @closed_when_used_up = closed_when_used_up || false
        @blocks = !!blocks
        @reachable = !!reachable
        @must_lay_together = !!must_lay_together
        @must_lay_all = @must_lay_together && !!must_lay_all
        @cost = cost
        @consume_tile_lay = consume_tile_lay || false
        @laid_hexes = []
      end
    end
  end
end
