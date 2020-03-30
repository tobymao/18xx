# frozen_string_literal: true

module Engine
  class Company
    include Ownable

    attr_reader :name, :sym, :value, :desc, :income, :blocks_hex

    def initialize(name, value:, income: 0, desc: '', sym: '', blocks_hex: nil)
      @name = name
      @value = value
      @desc = desc
      @income = income
      @sym = sym
      @blocks_hex = blocks_hex
      @open = true
    end

    def id
      @name
    end

    def min_bid
      @value
    end

    def min_price
      @value / 2
    end

    def max_price
      @value * 2
    end

    def open?
      @open
    end

    def close!
      @open = false
    end
  end
end
