# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class CreditMobilier < Base
      attr_reader :hex, :amount

      def initialize(entity, hex:, amount:)
        super(entity)
        @hex = hex
        @amount = amount
      end

      def self.h_to_args(h, game)
        {
          hex: game.hex_by_id(h['hex']),
          amount: h['amount'],
        }
      end

      def args_to_h
        {
          'hex' => @hex.id,
          'amount' => @amount,
        }
      end
    end
  end
end
