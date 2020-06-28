# frozen_string_literal: true

require_relative 'spender'

module Engine
  class Bank
    include Spender

    def initialize(cash, log: [])
      @cash = cash
      @log = log
      @broken = false
    end

    def check_cash(amount)
      return unless (@cash - amount).negative?

      @log << '-- The bank has broken --' unless @broken
      @broken = true
    end

    def broken?
      @broken
    end

    def name
      'The Bank'
    end
  end
end
