# frozen_string_literal: true

require_relative 'token'

module Engine
  class CorporationToken < Token
    attr_reader :corporation, :price

    def initialize(corporation, price: 0)
      super()
      @corporation = corporation
      @price = price
    end

    def logo
      @corporation.logo
    end
  end
end
