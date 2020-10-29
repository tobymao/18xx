# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class SellToBank < Base
      attr_reader :cost

      def setup(cost:)
        @cost = cost
      end
    end
  end
end
