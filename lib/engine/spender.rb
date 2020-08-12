# frozen_string_literal: true

require_relative 'game_error'

module Engine
  module Spender
    attr_accessor :cash

    def check_cash(amount)
      raise GameError, "#{name} has #{@cash} and cannot spend #{amount}" if (@cash - amount).negative?
    end

    def check_positive(amount)
      raise GameError, "#{amount} is not valid to spend" unless amount.positive?
    end

    def spend(cash, receiver, allow_overdraw = false)
      check_cash(cash) unless allow_overdraw
      check_positive(cash)
      @cash -= cash
      receiver.cash += cash
    end
  end
end
