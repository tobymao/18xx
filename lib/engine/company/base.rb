# frozen_string_literal: true

module Engine
  module Company
    class Base
      attr_reader :name, :value, :desc, :income

      def initialize(name, value:, income: 0, desc: '')
        @name = name
        @value = value
        @desc = desc
        @income = income
      end

      def min_bid
        @value
      end
    end
  end
end
