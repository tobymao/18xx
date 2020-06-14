# frozen_string_literal: true

require_relative 'ownable'
require_relative 'depot'

module Engine
  class Train
    include Ownable

    attr_reader :available_on, :name, :distance, :discount, :rusts_on, :rusted, :variant, :variants
    attr_accessor :unpurchasable

    def initialize(name:, distance:, price:, index: 0, **opts)
      @name = name
      @distance = distance
      @price = price
      @index = index
      @rusts_on = opts[:rusts_on]
      @available_on = opts[:available_on]
      @discount = opts[:discount]
      @unpurchasable = false
      @rusted = false
      setup_variants(opts[:variants])
    end

    def setup_variants(variants)
      return unless variants

      @variant = {
        name: @name,
        distance: @distance,
        price: @price,
        rusts_on: @rusts_on,
        discount: @discount,
      }

      variants << @variant
      @variants = variants.group_by { |h| h[:name] }.transform_values(&:first)
    end

    def variant=(variant)
      return unless variant

      @variants[variant]
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
