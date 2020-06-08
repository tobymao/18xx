# frozen_string_literal: true

require_relative 'token'

module Engine
  class NeutralToken < Token
    attr_reader :corporation, :price, :logo

    def initialize(logo, price: 0)
      super()
      @logo = logo
      @price = price
    end
  end
end
