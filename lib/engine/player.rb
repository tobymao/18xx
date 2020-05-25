# frozen_string_literal: true

require_relative 'passer'
require_relative 'share_holder'
require_relative 'spender'

module Engine
  class Player
    include Passer
    include ShareHolder
    include Spender

    attr_reader :name, :companies

    def initialize(name)
      @name = name
      @cash = 0
      @companies = []
    end

    def value
      @cash + shares.sum(&:price) + @companies.sum(&:value)
    end

    def id
      @name
    end

    def owner
      self
    end

    def player
      self
    end

    def ==(other)
      @name == other&.name
    end

    def player?
      true
    end

    def company?
      false
    end

    def corporation?
      false
    end

    def num_certs
      companies.count + shares.count { |s| s.corporation.counts_for_limit }
    end

    def to_s
      "#{self.class.name} - #{@name}"
    end

    def liquidity(round)
      value = cash
      shares_by_corporation.reject { |_, s| s.empty? }.each do |corporation, _|
        max_bundle = round.get_liquid_bundles(self, corporation).max_by(&:price)
        value += max_bundle&.price || 0
      end
      value
    end
  end
end
