# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class TrainDiscount < Base
      attr_reader :discount, :trains, :closed_when_used_up

      def setup(discount:, trains:, closed_when_used_up: nil)
        @discount = discount
        @trains = trains
        @closed_when_used_up = closed_when_used_up
      end

      def discounted_price(train, price)
        return price unless @trains.include?(train.name)

        discount_value = discount.is_a?(Hash) ? discount[train.name] : discount

        price - (discount_value > 1 ? discount_value : (price * discount_value))
      end
    end
  end
end
