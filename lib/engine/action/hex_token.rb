# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class HexToken < Base
      attr_reader :hex, :token, :cost

      def initialize(entity, hex:, cost: nil, token_type: nil, token: nil)
        super(entity)
        @hex = hex
        @cost = cost
        @token = token || @entity.find_token_by_type(token_type&.to_sym)
      end

      def self.h_to_args(h, game)
        {
          hex: game.hex_by_id(h['hex']),
          cost: h['cost'],
          token_type: h['token_type'],
        }
      end

      def args_to_h
        {
          'hex' => @hex.id,
          'cost' => @cost,
          'token_type' => @token&.type == :normal ? nil : @token&.type,
        }
      end
    end
  end
end
