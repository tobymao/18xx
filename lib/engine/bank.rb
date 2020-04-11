# frozen_string_literal: true

require_relative 'spender'

module Engine
  class Bank
    include Spender

    def initialize(cash)
      @cash = cash
    end

    def name
      'The Bank'
    end
  end
end
