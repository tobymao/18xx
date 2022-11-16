# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Stubs < Base
      attr_accessor :tiles
      attr_reader :hex_edges

      def setup(hex_edges:)
        @hex_edges = hex_edges
        @tiles = []
      end

      def teardown
        @tiles.each do |tile|
          tile.stubs.reject! { |stub| stub.owner == @owner }
        end
      end
    end
  end
end
