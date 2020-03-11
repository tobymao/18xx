# frozen_string_literal: true

require 'engine/ownable'
require 'engine/share'
require 'engine/spender'
require 'engine/token'

module Engine
  module Corporation
    class Base
      include Ownable
      include Spender

      attr_accessor :ipoed, :owner, :par_price, :share_price, :tokens
      attr_reader :coordinates, :sym, :name, :logo, :shares, :trains

      def initialize(sym, name:, tokens:, **opts)
        @sym = sym
        @name = name
        @tokens = tokens.times.map { Token.new(self) }
        @shares = [Share.new(self, president: true, percent: 20)] + 8.times.map { Share.new(self, percent: 10) }
        @shares.each_with_index { |s, index| s.index = index }
        @share_price = nil
        @par_price = nil
        @ipoed = false
        @trains = []

        @float_percent = opts[:float_percent] || 60
        @coordinates = opts[:coordinates]
        @logo = "logos/#{opts[:logo] || sym}.svg"
      end

      def buy_train(train, seller, price = nil)
        spend(price || train.price, seller)
        seller.trains.delete(train)
        @trains << train
      end

      def floated?
        @shares.sum(&:percent) <= 100 - @float_percent
      end
    end
  end
end
