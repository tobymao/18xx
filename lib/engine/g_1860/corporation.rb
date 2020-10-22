# frozen_string_literal: true

require_relative '../corporation'

module Engine
  module G1860
    class Corporation < Corporation
      attr_reader :layer, :par_range, :repar_range

      def initialize(sym:, name:, **opts)
        super

        @layer = opts[:layer] || 0
        @par_range = opts[:par_range] || []
        @repar_range = opts[:repar_range] || []
        @bankrupt = false
        @receivership = false
        @insolvent = false
      end

      def hi_par
        @bankrupt ? @repar_range.last : @par_range.last
      end

      def lo_par
        @bankrupt ? @repar_range.first : @par_range.first
      end

      def bankrupt?
        @bankrupt
      end

      def receivership?
        @receivership
      end

      def insolvent?
        @insolvent
      end
    end
  end
end
