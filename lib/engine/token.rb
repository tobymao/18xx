# frozen_string_literal: true

module Engine
  class Token
    attr_reader :corporation, :price, :logo

    def initialize(corporation, price: 0, logo: nil)
      @corporation = corporation
      @price = price
      @logo = logo || corporation.logo
      @used = false
    end

    def used?
      @used
    end

    def use!
      @used = true
    end
  end
end
