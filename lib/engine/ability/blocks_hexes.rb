# frozen_string_literal: true

require_relative 'base'
require_relative '../hex'

module Engine
  module Ability
    class BlocksHexes < Base
      attr_accessor :hexes
      attr_reader :blocks_owning_player

      def setup(hexes:, hidden: false, blocks_owning_player: true)
        @hexes = hexes
        @hidden = hidden
        @blocks_owning_player = blocks_owning_player
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
