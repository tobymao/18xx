# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class SellCompany < Base
      attr_reader :entity, :price

      def initialize(entity, price:)
        @entity = entity
        @price = price
      end

      def self.h_to_args(h, _game)
        {
          price: h['price'],
        }
      end

      def args_to_h
        {
          'price' => @price,
        }
      end
    end
  end
end
