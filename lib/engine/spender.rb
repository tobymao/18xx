# frozen_string_literal: true

require_relative 'game_error'

module Engine
  module Spender
    attr_accessor :cash

    def check_cash(amount)
      amount.bad_func if (@cash - amount).negative?
      raise GameError, "#{name} has #{@cash} and cannot spend #{amount}" if (@cash - amount).negative?
    end

    def check_positive(amount)
      raise GameError, "#{amount} is not valid to spend" unless amount.positive?
    end

    def spend(cash, receiver, check_cash: true, check_positive: true)
      self.check_cash(cash) if check_cash
      check_positive(cash) if check_positive
      @cash -= cash
      receiver.cash += cash
    end
  end
end
