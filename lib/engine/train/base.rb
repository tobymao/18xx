# frozen_string_literal: true

require 'engine/ownable'
require 'engine/train/depot'

module Engine
  module Train
    class Base
      include Ownable

      attr_reader :name, :distance, :price

      def initialize(name, distance:, price:, index: 0)
        @name = name
        @distance = distance
        @price = price
        @index = index
      end

      def id
        "#{@name}-#{@index}"
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
