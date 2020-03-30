# frozen_string_literal: true

module Engine
  class Company
    include Ownable

    attr_reader :name, :sym, :value, :desc, :income, :blocks_hex

    def initialize(name:, value:, income: 0, desc: '', sym: '', abilities: [])
      @name = name
      @value = value
      @desc = desc
      @income = income
      @sym = sym
      @open = true

      init_abilities(abilities)
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

    private

    def init_abilities(abilities)
      abilities.each do |ability|
        case ability[:type]
        when :blocks_hex
          @blocks_hex = ability[:hex]
        end
      end
    end
  end
end
