# frozen_string_literal: true

require_relative 'ownable'

module Engine
  class Loan
    include Ownable

    attr_reader :id, :amount

    def initialize(id, amount)
      @id = id
      @amount = amount
    end
  end
end
