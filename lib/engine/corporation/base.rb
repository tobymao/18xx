# frozen_string_literal: true

require 'engine/ownable'
require 'engine/share'
require 'engine/token'

module Engine
  module Corporation
    class Base
      include Ownable

      attr_accessor :ipoed, :owner, :par_price, :share_price, :tokens
      attr_reader :coordinates, :sym, :name, :logo, :shares

      def initialize(sym, name:, tokens:, **opts)
        @sym = sym
        @name = name
        @tokens = tokens.times.map { Token.new(self) }
        @shares = [Share.new(self, president: true, percent: 20)] + 8.times.map { Share.new(self, percent: 10) }
        @shares.each_with_index { |s, index| s.index = index }
        @share_price = nil
        @par_price = nil
        @ipoed = false

        @float_percent = opts[:float_percent] || 60
        @coordinates = opts[:home_coordinates]
        @logo = "logos/#{opts[:logo] || sym}.svg"
      end

      def floated?
        @shares.sum(&:percent) <= 100 - @float_percent
      end
    end
  end
end
