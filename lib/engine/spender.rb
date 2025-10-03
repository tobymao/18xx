# frozen_string_literal: true

require_relative 'game_error'

module Engine
  module Spender
    attr_accessor :cash

    def debt
      @debt || 0
    end

    def check_cash(amount, borrow_from: nil)
      available = @cash + (borrow_from ? borrow_from.cash : 0)
      raise GameError, "#{name} has #{@cash} and cannot spend #{amount}" if (available - amount).negative?
    end

    def check_positive(amount)
      raise GameError, "#{amount} is not valid to spend" unless amount.positive?
    end

    def check_receiver(cash, receiver)
      raise GameError, "Cash receiver must be a different entity: #{name}.spend(#{cash}, #{receiver.name})" if receiver == self
    end

    def spend(cash, receiver, check_cash: true, check_positive: true, borrow_from: nil)
      check_receiver(cash, receiver)

      cash = cash.to_i
      self.check_cash(cash, borrow_from: borrow_from) if check_cash
      self.check_positive(cash) if check_positive

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

    def take_cash_loan(cash, bank, interest: 0)
      bank.spend(cash, self)

      total_debt = cash + interest_amount(cash, interest)
      self.debt += total_debt
      bank.debt -= total_debt

      { cash: cash, debt: total_debt }
    end

    def take_interest(bank, interest: 0)
      added_interest = interest_amount(self.debt, interest)
      self.debt += added_interest
      bank.debt -= added_interest
      added_interest
    end

    def repay_cash_loan(bank, payoff_amount: nil)
      amount = [payoff_amount || cash, self.debt].min

      spend(amount, bank)
      self.debt -= amount
      bank.debt += amount

      amount
    end

    protected

    def debt=(amount)
      @debt = amount
    end

    private

    def interest_amount(amount, rate)
      (amount * rate / 100.0).ceil
    end
  end
end
