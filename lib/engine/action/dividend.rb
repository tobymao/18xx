# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class Dividend < Base
      attr_reader :amount, :kind

      def initialize(entity, kind:, amount: nil)
        super(entity)
        @kind = kind
        @amount = amount
      end

      def self.h_to_args(h, _game)
        {
          kind: h['kind'],
          amount: h['amount'],
        }
      end

      def args_to_h
        {
          'kind' => @kind,
          'amount' => @amount,
        }
      end
    end
  end
end
