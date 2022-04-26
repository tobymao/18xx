# frozen_string_literal: true

require_relative 'city'

module Engine
  module Part
    class Pass < City
      attr_reader :color, :size

      def initialize(revenue, **opts)
        super
        @color = (opts[:color] || 'gray').to_sym
        @size = (opts[:size] || 1).to_i
      end

      def pass?
        true
      end
    end
  end
end
