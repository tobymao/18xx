# frozen_string_literal: true

require 'engine/ownable'
require 'engine/train/depot'

module Engine
  module Train
    class Base
      include Ownable

      attr_accessor :id
      attr_reader :name, :distance, :price

      def initialize(name, distance:, price:)
        @name = name
        @distance = distance
        @price = price
      end

      def rust!
        owner.remove_train(self)
        @owner = nil
      end

      def min_price
        owner.is_a?(Depot) ? @price : 1
      end
    end
  end
end
