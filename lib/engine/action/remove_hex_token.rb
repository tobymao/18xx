# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class RemoveHexToken < Base
      attr_reader :hex

      def initialize(entity, hex:)
        super(entity)
        @hex = hex
      end

      def self.h_to_args(h, game)
        {
          hex: game.hex_by_id(h['hex']),
        }
      end

      def args_to_h
        {
          'hex' => @hex.id,
        }
      end
    end
  end
end
