# frozen_string_literal: true

require 'engine/ownable'
require 'engine/passer'
require 'engine/share'
require 'engine/share_holder'
require 'engine/spender'
require 'engine/token'

module Engine
  module Corporation
    class Base
      include Ownable
      include Passer
      include ShareHolder
      include Spender

      attr_accessor :ipoed, :par_price, :share_price, :tokens
      attr_reader :coordinates, :sym, :name, :logo, :trains

      def initialize(sym, name:, tokens:, **opts)
        @sym = sym
        @name = name
        @tokens = tokens.times.map { Token.new(self) }
        shares = [Share.new(self, president: true, percent: 20)] + 8.times.map { Share.new(self, percent: 10) }
        shares.each_with_index do |share, index|
          share.index = index
          shares_by_corporation[self] << share
        end
        @share_price = nil
        @par_price = nil
        @ipoed = false
        @trains = []

        @cash = 0
        @float_percent = opts[:float_percent] || 60
        @coordinates = opts[:coordinates]
        @logo = "logos/#{opts[:logo] || sym}.svg"
      end

      def buy_train(train, price = nil)
        spend(price || train.price, train.owner)
        train.owner.remove_train(train)
        train.owner = self
        @trains << train
      end

      def remove_train(train)
        @trains.delete(train)
      end

      def floated?
        percent_of(self) <= 100 - @float_percent
      end
    end
  end
end
