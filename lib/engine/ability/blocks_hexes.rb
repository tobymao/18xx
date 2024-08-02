# frozen_string_literal: true

require_relative 'base'
require_relative '../hex'

module Engine
  module Ability
    class BlocksHexes < Base
      attr_accessor :hexes

      def setup(hexes:, hidden: false)
        @hexes = hexes
        @hidden = hidden
      end

      def hidden?
        @hidden
      end

      def teardown
        @hexes.each { |hex| hex.tile.remove_blocker!(owner) if hex.is_a?(Engine::Hex) }
      end
    end
  end
end
