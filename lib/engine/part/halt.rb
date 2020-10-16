# frozen_string_literal: true

require_relative 'town'

module Engine
  module Part
    class Halt < Town
      attr_reader :symbol

      def initialize(symbol, **opts)
        @revenue = parse_revenue('0', opts[:format])
        @groups = (opts[:groups] || '').split('|')
        @hide = opts[:hide]
        @visit_cost = (opts[:visit_cost] || 1).to_i
        @loc = opts[:loc]

        @route = (opts[:route] || :mandatory).to_sym
        @symbol = symbol
      end

      def halt?
        true
      end
    end
  end
end
