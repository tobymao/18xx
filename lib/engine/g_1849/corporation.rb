# frozen_string_literal: true

require_relative 'corporation'

module Engine
  module G1849
    class Corporation < Corporation
      attr_reader :token_fee
      attr_accessor :next_to_par, :closed_recently

      def initialize(sym:, name:, **opts)
        super
        @token_fee = opts[:token_fee]
      end
    end
  end
end
