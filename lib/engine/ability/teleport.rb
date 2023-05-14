# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Teleport < Base
      attr_reader :tiles, :cost, :free_tile_lay, :from_owner, :extra_action
      attr_accessor :hexes

      def setup(hexes:, tiles:, cost: nil, free_tile_lay: false, from_owner: true, extra_action: nil)
        @hexes = hexes
        @tiles = tiles
        @cost = cost
        @free_tile_lay = free_tile_lay
        @when = %w[track] if @when.empty?
        @passive = false
        @from_owner = from_owner
        @extra_action = extra_action || false
      end
    end
  end
end
