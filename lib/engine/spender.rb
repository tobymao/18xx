# frozen_string_literal: true

require 'engine/game_error'

module Engine
  module Spender
    attr_accessor :cash

    def check_cash
      raise GameError("Player #{name} has #{@cash} and cannot spend #{cash}") if @cash.negative?
    end

    def spend(cash, receiver)
      @cash -= cash
      receiver.cash += cash
      check_cash
    end
  end
end
