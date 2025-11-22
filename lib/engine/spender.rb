# frozen_string_literal: true

require_relative 'game_error'

module Engine
  module Spender
    attr_reader :cash

    def spender
      self
    end

    def debt
      @debt ||= 0
    end

    def spend(cash, receiver, check_cash: true, check_positive: true, borrow_from: nil)
      receiver = receiver.spender

      cash = cash.to_i
      check_receiver(cash, receiver)
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

    def set_cash(cash, other_spender)
      other_spender.spend(cash - self.cash, self, check_cash: false, check_positive: false)
    end

    def take_cash_loan(cash, bank, interest: 0)
      bank.spend(cash, self)

      debt = cash + interest_amount(cash, interest)
      self.debt += debt
      bank.debt -= debt

      { cash: cash, debt: debt }
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

    # This is protected so that only `spend()` can call this directly, to ensure
    # that no money is ever "dropped on the floor", or conjured from nothing
    # when The Bank should be used.
    def cash=(cash)
      @cash = cash
    end

    def debt=(amount)
      @debt = amount
    end

    private

    def check_cash(amount, borrow_from: nil)
      available = @cash + (borrow_from ? borrow_from.cash : 0)
      raise GameError, "#{name} has #{@cash} and cannot spend #{amount}" if (available - amount).negative?
    end

    def check_positive(amount)
      raise GameError, "Cannot spend zero or negative money in Spender.spend(#{amount})" unless amount.positive?
    end

    def check_receiver(cash, receiver)
      return unless receiver == self

      raise GameError, "Cash spender and receiver must be different entities: #{name}.spend(#{cash}, #{receiver.name})"
    end

    def interest_amount(amount, rate)
      (amount * rate / 100.0).ceil
    end
  end
end
