# frozen_string_literal: true

require 'engine/share'

module Engine
  module Corporation
    class Base
      attr_accessor :ipoed, :par_price, :share_price
      attr_reader :sym, :name, :shares

      def initialize(sym, name:, tokens:)
        @sym = sym
        @name = name
        @tokens = tokens
        @shares = [Share.new(self, president: true, percent: 20)] + 8.times.map { Share.new(self, percent: 10) }
        @shares.each_with_index { |s, index| s.index = index }
        @share_price = nil
        @par_price = nil
        @ipoed = false
      end
    end
  end
end
