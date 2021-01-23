# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Exchange < Base
      attr_reader :from, :corporations

      def setup(corporations:, from:)
        @corporations = corporations
        @from = Array(from).map(&:to_sym)
      end
    end
  end
end
