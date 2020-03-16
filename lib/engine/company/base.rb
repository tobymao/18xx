# frozen_string_literal: true

require 'engine/corporation/base'
require 'engine/ownable'

module Engine
  module Company
    class Base
      include Ownable

      attr_reader :name, :value, :desc, :income, :blocks_hex

      def initialize(name, value:, income: 0, desc: '', blocks_hex: nil)
        @name = name
        @value = value
        @desc = desc
        @income = income
        @blocks_hex = blocks_hex
        @open = true
      end

      def id
        @name
      end

      def min_bid
        @value
      end

      def open?
        @open
      end

      def close!
        @open = false
      end
    end
  end
end
