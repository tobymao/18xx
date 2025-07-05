# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class FloatCost < Base
      attr_accessor :float_cost

      def setup(float_cost:)
        @float_cost = float_cost
      end
    end
  end
end
