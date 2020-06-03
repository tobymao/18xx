# frozen_string_literal: true

require_relative 'ownable'
require_relative 'depot'

module Engine
  class Train
    include Ownable

    attr_reader :available_on, :name, :distance, :discount, :rusts_on, :rusted

    def initialize(name:, distance:, price:, index: 0, **opts)
      @name = name
      @distance = distance
      @price = price
      @index = index
      @rusts_on = opts[:rusts_on]
      @available_on = opts[:available_on]
      @discount = opts[:discount]
      @rusted = false
    end

    def price(exchange_train = nil)
      @price - (@discount&.dig(exchange_train&.name) || 0)
    end

    def id
      "#{@name}-#{@index}"
    end

    def rust!
      owner&.remove_train(self)
      @owner = nil
      @rusted = true
    end

    def min_price
      from_depot? ? @price : 1
    end

    def from_depot?
      owner.is_a?(Depot)
    end

    def inspect
      "<Train: #{id}>"
    end
  end
end
