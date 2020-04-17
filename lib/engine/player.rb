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
  end
end
