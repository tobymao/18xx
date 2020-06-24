# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Bonus < Base
      def type
        :bonus
      end

      def calculate_revenue(_route)
        raise NotImplementedError
      end
    end
  end
end
