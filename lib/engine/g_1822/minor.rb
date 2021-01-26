# frozen_string_literal: true

require_relative '../minor'

module Engine
  module G1822
    class Minor < Minor
      attr_accessor :type, :removed, :share_price, :max_share_price
      attr_writer :par_price

      def initialize(sym:, name:, **opts)
        @type = opts[:type]&.to_sym
        @removed = false
        @share_price = nil
        @par_price = nil

        super
      end

      def par_price
        @share_price
      end
    end
  end
end
