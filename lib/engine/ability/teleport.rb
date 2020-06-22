# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Teleport < Base
      attr_reader :hexes, :tiles

      def setup(hexes:, tiles:)
        @hexes = hexes
        @tiles = tiles
      end
    end
  end
end
