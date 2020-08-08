# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class TileLay < Base
      attr_reader :hexes, :tiles, :free, :discount, :special

      def setup(hexes:, tiles:, free: false, discount: nil, special: nil)
        @hexes = hexes
        @tiles = tiles
        @free = free
        @discount = discount || 0
        @special = special.nil? ? true : special
      end
    end
  end
end
