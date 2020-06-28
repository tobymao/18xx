# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class RevenueChange < Base
      attr_reader :revenue

      def setup(revenue:)
        @revenue = revenue
      end
    end
  end
end
