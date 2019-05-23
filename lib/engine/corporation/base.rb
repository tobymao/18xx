# frozen_string_literal: true

module Engine
  module Corporation
    class Base
      attr_accessor :par_price, :share_price
      attr_reader :shares

      def initialize(key, name:, tokens:)
        @key = key
        @name = name
        @tokens = tokens
        @shares = []
        @share_price = nil
        @par_price = nil
      end
    end
  end
end
