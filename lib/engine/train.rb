# frozen_string_literal: true

require_relative 'ownable'
require_relative 'depot'

module Engine
  class Train
    include Ownable

    attr_accessor :obsolete, :operated
    attr_reader :available_on, :name, :distance, :discount, :obsolete_on,
                :rusts_on, :rusted, :sym, :variant, :variants
    attr_writer :buyable

    def initialize(name:, distance:, price:, index: 0, **opts)
      @sym = name
      @name = name
      @distance = distance
      @price = price
      @index = index
      @rusts_on = opts[:rusts_on]
      @obsolete_on = opts[:obsolete_on]
      @available_on = opts[:available_on]
      @discount = opts[:discount]
      @buyable = true
      @rusted = false
      @obsolete = false
      @operated = false
      init_variants(opts[:variants])
    end

    def init_variants(variants)
      variants ||= []

      @variant = {
        name: @name,
        distance: @distance,
        price: @price,
        rusts_on: @rusts_on,
        obsolete_on: @obsolete_on,
        discount: @discount,
      }

      variants << @variant
      @variants = variants.group_by { |h| h[:name] }.transform_values(&:first)
    end

    def variant=(new_variant)
      return unless new_variant

      @variant = @variants[new_variant]
      @variant.each { |k, v| instance_variable_set("@#{k}", v) }
    end

    def names_to_prices
      @variants.transform_values { |v| v[:price] }
    end

    def price(exchange_train = nil)
      @price - (@discount&.dig(exchange_train&.name) || 0)
    end

    def id
      "#{@sym}-#{@index}"
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

    def buyable
      @buyable && !@obsolete
    end

    def inspect
      "<Train: #{id}>"
    end
  end
end
