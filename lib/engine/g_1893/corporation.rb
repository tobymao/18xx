# frozen_string_literal: true

require_relative '../corporation'

module Engine
  module G1893
    class Corporation < Corporation
      attr_accessor :floatable

      def initialize(sym:, name:, **opts)
        @floatable = true
        super
      end

      def floated?
        @floatable && super
      end
    end
  end
end
