# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class RemoveBorder < Base
      attr_reader :hex, :edge

      def initialize(entity, hex:, edge:)
        super(entity)
        @hex = hex
        @edge = edge
      end

      def self.h_to_args(h, game)
        {
          hex: game.hex_by_id(h['hex']),
          edge: h['edge'],
        }
      end

      def args_to_h
        {
          'hex' => @hex.id,
          'edge' => @edge,
        }
      end
    end
  end
end
