# frozen_string_literal: true

require 'engine/ownable'

module Engine
  module Train
    class Base
      include Ownable

      attr_accessor :id
      attr_reader :name, :distance, :price, :phase, :rusts

      def initialize(name, distance:, price:, phase:, rusts: nil)
        @name = name
        @distance = distance
        @price = price
        @phase = phase
        @rusts = Array(rusts)
      end
    end
  end
end
