# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class TileLay < Base
      attr_reader :hexes, :tiles, :free, :discount

      def setup(hexes:, tiles:, free: false, discount: nil)
        @hexes = hexes
        @tiles = tiles
        @free = free
        @discount = discount || 0
      end
    end
  end
end
