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

    def initialize(cash, log: [], check: true)
      @cash = cash
      @log = log
      @broken = false
      @companies = []
      @check = check

      # should be zero-sum with players' @debt
      @debt = 0
    end

    def check_cash(amount, borrow_from: nil)
      return unless @check
      return unless (@cash - amount).negative?

      break!
    end

    def break!
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
