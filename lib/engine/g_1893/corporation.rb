# frozen_string_literal: true

require_relative '../corporation'

module Engine
  module G1893
    class Corporation < Corporation
      attr_accessor :floatable

      def initialize(sym:, name:, **opts)
        super
        @floatable = true
        return if sym != 'AGV' && sym != 'HGK'

        shares[0].buyable = false
        shares[1].buyable = false
        shares[2].buyable = false
        shares[2].double_cert = true
      end

      def floated?
        @floatable && super
      end
    end
  end
end
