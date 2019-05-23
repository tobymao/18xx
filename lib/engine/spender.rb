# frozen_string_literal: true

require 'engine/game_error'

module Engine
  module Spender
    attr_reader :cash

    def check_cash
      raise GameError("Player #{name} has #{@cash} and cannot spend #{cash}") if @cash.negative?
    end

    def remove_cash(cash)
      @cash -= cash
      check_cash
    end

    def add_cash(cash)
      @cash += cash
    end
  end
end
