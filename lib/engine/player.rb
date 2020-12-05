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
    attr_reader :name, :companies, :id, :history

    def initialize(id, name)
      @id = id
      @name = name
      @cash = 0
      @companies = []
      @history = []
    end

    def value
      @cash + shares.select { |s| s.corporation.ipoed }.sum(&:price) + @companies.sum(&:value)
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

    def to_s
      "#{self.class.name} - #{@name}"
    end
  end
end
