# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class PayoffPlayerDebtPartial < Base
      attr_reader :amount

      def initialize(entity, amount:)
        super(entity)
        @amount = amount
      end

      def self.h_to_args(h, _game)
        {
          amount: h['amount'],
        }
      end

      def args_to_h
        {
          'amount' => @amount,
        }
      end
    end
  end
end
