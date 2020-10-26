# frozen_string_literal: true

require_relative 'abilities'
require_relative 'entity'
require_relative 'ownable'

module Engine
  class Company
    include Abilities
    include Entity
    include Ownable

    attr_accessor :desc, :max_price, :min_price, :revenue, :discount
    attr_reader :name, :sym, :value, :min_auction_price, :treasury

    def initialize(sym:, name:, value:, revenue: 0, desc: '', abilities: [], **opts)
      @sym = sym
      @name = name
      @value = value
      @treasury = opts[:treasury] || @value
      @desc = desc
      @revenue = revenue
      @discount = opts[:discount] || 0
      @min_auction_price = -@discount
      @closed = false
      @min_price = @value / 2
      @max_price = @value * 2

      init_abilities(abilities)
    end

    def <=>(other)
      [min_bid, name] <=> [other.min_bid, other.name]
    end

    def id
      @sym
    end

    def min_bid
      @value - @discount
    end

    def close!
      @closed = true

      all_abilities.dup.each { |a| remove_ability(a) }
      return unless owner

      owner.companies.delete(self)
      @owner = nil
    end

    def closed?
      @closed
    end

    def company?
      true
    end

    def border?
      false
    end

    def path?
      false
    end

    def find_token_by_type(token_type)
      raise GameError, "#{name} does not have a token" unless abilities(:token)

      return @owner.find_token_by_type(token_type) if abilities(:token).from_owner

      Token.new(@owner)
    end

    def inspect
      "<#{self.class.name}: #{id}>"
    end
  end
end
