# frozen_string_literal: true

require 'engine/ownable'
require 'engine/passer'
require 'engine/share'
require 'engine/share_holder'
require 'engine/spender'
require 'engine/token'

module Engine
  class Corporation
    include Ownable
    include Passer
    include ShareHolder
    include Spender

    attr_accessor :ipoed, :par_price, :share_price, :tokens
    attr_reader :companies, :coordinates, :min_price, :sym, :name, :logo, :trains

    def initialize(sym:, name:, tokens:, **opts)
      @sym = sym
      @name = name
      @tokens = tokens.times.map { Token.new(self) }
      [
        Share.new(self, president: true, percent: 20),
        *8.times.map { |index| Share.new(self, percent: 10, index: index + 1) }
      ].each { |share| shares_by_corporation[self] << share }

      @share_price = nil
      @par_price = nil
      @ipoed = false
      @trains = []
      @companies = []

      @cash = 0
      @float_percent = opts[:float_percent] || 60
      @coordinates = opts[:coordinates]
      @min_price = opts[:min_price]
      @logo = "logos/#{opts[:logo] || sym}.svg"
    end

    def share_holders
      @share_holders ||= Hash.new(0)
    end

    def id
      @sym
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
