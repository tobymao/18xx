# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class TrainLimit < Base
      attr_reader :increase, :constant

      def setup(increase: nil, constant: nil)
        @increase = increase
        @constant = constant
      end
    end
  end
end
