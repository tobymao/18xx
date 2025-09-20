# frozen_string_literal: true

require_relative 'game_error'

module Engine
  module Spender
    attr_accessor :cash

    def check_cash(amount, borrow_from: nil)
      available = @cash + (borrow_from ? borrow_from.cash : 0)
      raise GameError, "#{name} has #{@cash} and cannot spend #{amount}" if (available - amount).negative?
    end

    def check_positive(amount)
      raise GameError, "#{amount} is not valid to spend" unless amount.positive?
    end

    def spend(cash, receiver, check_cash: true, check_positive: true, borrow_from: nil)
      cash = cash.to_i
      self.check_cash(cash, borrow_from: borrow_from) if check_cash
      check_positive(cash) if check_positive

      # Check if we need to borrow from our borrow_from target
      if borrow_from && (cash > @cash)
        amount_borrowed = cash - @cash
        @cash = 0
        borrow_from.cash -= amount_borrowed
      else
        @cash -= cash
      end

      receiver.cash += cash
    end
  end
end
