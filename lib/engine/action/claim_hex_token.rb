# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class ClaimHexToken < Base
      attr_reader :hex, :token_type

      def initialize(entity, hex:, token_type: nil)
        super(entity)
        @hex = hex
        @token_type = token_type
      end

      def self.h_to_args(h, game)
        {
          hex: game.hex_by_id(h['hex']),
          token_type: h['token_type'],
        }
      end

      def args_to_h
        {
          'hex' => @hex.id,
          'token_type' => @token_type,
        }
      end
    end
  end
end
