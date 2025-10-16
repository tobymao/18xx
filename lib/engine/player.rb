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

    attr_accessor :bankrupt, :penalty
    attr_reader :name, :companies, :id, :history, :unsold_companies

    def initialize(id, name)
      @id = id
      @name = name
      @cash = 0
      @companies = []
      @history = []
      @unsold_companies = []
      @penalty = 0
    end

    def value
      @cash + shares.select { |s| s.corporation.ipoed }.sum(&:price) + @companies.sum(&:value) - debt - @penalty
    end

    def owner
      self
    end

    def player
      self
    end

    def corporation
      nil
    end

    def ==(other)
      !!other&.player? && (@name == other.name)
    end

    def player?
      true
    end

    def rename!(new_name)
      @name = new_name
    end

    def to_s
      "#{self.class.name} - #{@name}"
    end

    def inspect
      "<#{self.class.name} - #{@name}>"
    end
  end
end
