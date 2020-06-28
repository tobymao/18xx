# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class TileLay < Base
      attr_reader :hexes, :tiles, :free

      def setup(hexes:, tiles:, free: false)
        @hexes = hexes
        @tiles = tiles
        @free = free
      end
    end
  end
end
