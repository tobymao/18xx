# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class TrainLimit < Base
      attr_reader :increase
      def setup(increase: nil)
        @increase = increase
      end
    end
  end
end
