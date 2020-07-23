# frozen_string_literal: true

require_relative 'abilities'
require_relative 'ownable'

module Engine
  class Company
    include Abilities
    include Ownable

    attr_accessor :desc, :max_price, :min_price, :revenue, :discount
    attr_reader :name, :sym, :value

    def initialize(sym:, name:, value:, revenue: 0, desc: '', abilities: [], **opts)
      @sym = sym
      @name = name
      @value = value
      @desc = desc
      @revenue = revenue
      @discount = opts[:discount] || 0
      @closed = false
      @min_price = @value / 2
      @max_price = @value * 2

      init_abilities(abilities)
    end

    def operator?
      false
    end

    def id
      @sym
    end

    def min_bid
      @value - @discount
    end

    def close!
      @closed = true

      all_abilities.each { |a| remove_ability(a) }
      return unless owner

      owner.companies.delete(self)
      @owner = nil
    end

    def closed?
      @closed
    end

    def player?
      false
    end

    def company?
      true
    end

    def corporation?
      false
    end

    def find_token_by_type(_token_type)
      raise GameError, "#{name} does not have a token" unless abilities(:token)

      Token.new(@owner)
    end

    def inspect
      "<#{self.class.name}: #{id}>"
    end
  end
end
