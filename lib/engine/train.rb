# frozen_string_literal: true

require_relative 'ownable'
require_relative 'depot'

module Engine
  class Train
    include Ownable

    attr_accessor :obsolete, :operated, :events, :variants, :obsolete_on, :rusted, :rusts_on, :index, :name,
                  :distance, :reserved
    attr_reader :available_on, :discount, :multiplier, :sym, :variant
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
      @multiplier = opts[:multiplier]
      @no_local = opts[:no_local]
      @buyable = true
      @rusted = false
      @obsolete = false
      @operated = false
      @events = (opts[:events] || []).select { |e| @index == (e[:when] || 0) }
      @reserved = opts[:reserved] || false
      init_variants(opts[:variants])
    end

    def init_variants(variants)
      variants ||= []

      @variant = {
        name: @name,
        distance: @distance,
        multiplier: @multiplier,
        price: @price,
        rusts_on: @rusts_on,
        obsolete_on: @obsolete_on,
        discount: @discount,
      }

      # Primary variant should be at the head of the list.
      variants.unshift(@variant)
      @variants = variants.group_by { |h| h[:name] }.transform_values(&:first)
    end

    def variant=(new_variant)
      return unless new_variant

      @variant = @variants[new_variant]
      @variant.each { |k, v| instance_variable_set("@#{k}", v) }

      # Remove the @local variable, this to get the local? method evaluate the new variant
      remove_instance_variable(:@local) if defined?(@local)
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

    # if set ability must be a :train_discount ability
    def min_price(ability: nil)
      return 1 unless from_depot?

      ability&.discounted_price(self, @price) || @price
    end

    def from_depot?
      owner.is_a?(Depot)
    end

    def buyable
      @buyable && !@obsolete
    end

    def local?
      return false if @no_local
      return @local if defined?(@local)

      @local = if @distance.is_a?(Numeric)
                 @distance == 1
               else
                 distance_city = @distance.find { |n| n['nodes'].include?('city') }
                 distance_city['visit'] == 1 if distance_city
               end
    end

    def inspect
      "<Train: #{id}>"
    end
  end
end
