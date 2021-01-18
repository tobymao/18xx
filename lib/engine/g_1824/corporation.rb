# frozen_string_literal: true

require_relative '../corporation'

module Engine
  module G1824
    class Corporation < Corporation
      attr_accessor :floatable, :removed

      def initialize(sym:, name:, **opts)
        @floatable = true
        @removed = false
        super
      end

      def floated?
        @floatable && super
      end
    end
  end
end
