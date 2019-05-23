# frozen_string_literal: true

require 'engine/spender'

module Engine
  class Bank
    include Spender

    def initialize(cash)
      @cash = cash
    end
  end
end
