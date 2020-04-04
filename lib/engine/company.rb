# frozen_string_literal: true

require 'engine/ownable'

module Engine
  class Company
    include Ownable

    attr_reader :abilities, :name, :sym, :value, :desc, :income

    def initialize(name:, value:, income: 0, desc: '', sym: '', abilities: [])
      @name = name
      @value = value
      @desc = desc
      @income = income
      @sym = sym
      @open = true

      @abilities = abilities
        .group_by { |ability| ability[:type] }
        .transform_values(&:first)
    end

    def remove_ability(type)
      @abilities.delete(type)
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
