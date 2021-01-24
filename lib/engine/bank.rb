# frozen_string_literal: true

require_relative 'entity'
require_relative 'share_holder'
require_relative 'spender'

module Engine
  class Bank
    include Entity
    include ShareHolder
    include Spender

    attr_reader :companies

    def initialize(cash, log: [])
      @cash = cash
      @log = log
      @broken = false
      @companies = []
    end

    def check_cash(amount)
      return unless (@cash - amount).negative?

      @log << '-- The bank has broken --' unless @broken
      @broken = true
    end

    def broken?
      @broken
    end

    def player
      nil
    end

    def name
      'The Bank'
    end

    def inspect
      "<#{self.class.name}>"
    end
  end
end
