# frozen_string_literal: true

require 'engine/ownable'

module Engine
  module Company
    class Base
      include Ownable

      attr_accessor :owner
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
