# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class TileLay < Base
      attr_reader :hexes, :tiles, :free, :discount, :special_lay

      def setup(hexes:, tiles:, free: false, discount: nil, special_lay: true)
        @hexes = hexes
        @tiles = tiles
        @free = free
        @discount = discount || 0
        @special_lay = special_lay
      end
    end
  end
end
