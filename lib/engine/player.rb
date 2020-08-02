# frozen_string_literal: true

require_relative 'entity'
require_relative 'passer'
require_relative 'share_holder'
require_relative 'spender'

module Engine
  class Player
    include Entity
    include Passer
    include ShareHolder
    include Spender

    attr_accessor :bankrupt
    attr_reader :name, :companies

    def initialize(name, count_companies: true)
      @name = name
      @cash = 0
      @companies = []
      @count_companies = count_companies
    end

    def value
      @cash + shares.select { |s| s.corporation.ipoed }.sum(&:price) + @companies.sum(&:value)
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

    def num_certs
      num_companies = @count_companies ? companies.size : 0
      num_companies + shares.count { |s| s.corporation.counts_for_limit }
    end

    def to_s
      "#{self.class.name} - #{@name}"
    end
  end
end
