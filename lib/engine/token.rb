# frozen_string_literal: true

module Engine
  class Token
    attr_reader :corporation, :price, :logo, :type

    def initialize(corporation, price: 0, logo: nil, type: :normal)
      @corporation = corporation
      @price = price
      @logo = logo || corporation.logo
      @used = false
      @type = type
    end

    def used?
      @used
    end

    def use!
      @used = true
    end
  end
end
