# frozen_string_literal: true

require_relative 'abilities'
require_relative 'entity'
require_relative 'ownable'
require_relative 'passer'

module Engine
  class Company
    include Abilities
    include Entity
    include Ownable
    include Passer

    attr_accessor :name, :desc, :min_price, :revenue, :discount, :value
    attr_reader :sym, :min_auction_price, :treasury, :interval, :color, :text_color, :type
    attr_writer :max_price

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
      @min_price = opts[:min_price] || (@value ? (@value / 2.0).ceil : nil)
      @max_price = opts[:max_price] || (@value ? (@value * 2) : nil)
      @interval = opts[:interval] # Array of prices or nil
      @color = opts[:color] || :yellow
      @text_color = opts[:text_color] || :black
      @type = opts[:type]&.to_sym

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

      owner.companies.delete(self) if owner.respond_to?(:companies)
      @owner = nil
    end

    def closed?
      @closed
    end

    def company?
      true
    end

    def path?
      false
    end

    def find_token_by_type(token_type)
      token_ability = all_abilities.find { |a| a.type == :token }
      raise GameError, "#{name} does not have a token" unless token_ability

      return @owner.find_token_by_type(token_type) if token_ability.from_owner

      Token.new(@owner)
    end

    def inspect
      "<#{self.class.name}: #{id}>"
    end

    def max_price(_buyer = nil)
      @max_price
    end
  end
end
