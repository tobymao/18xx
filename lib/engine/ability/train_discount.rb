# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class TrainDiscount < Base
      attr_reader :discount, :trains
      def setup(discount:, trains:)
        @discount = discount
        @trains = trains
      end

      def discounted_price(train, price)
        return price unless @trains.include?(train.name)

        price - (discount > 1 ? discount : (price * discount))
      end
    end
  end
end
