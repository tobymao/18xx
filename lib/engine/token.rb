# frozen_string_literal: true

module Engine
  class Token
    attr_reader :corporation, :price

    def initialize(corporation, price: 0)
      @corporation = corporation
      @price = price
      @used = false
    end

    def used?
      @used
    end

    def use!
      @used = true
    end

    def matches(other)
      other.class == Token && @corporation.name == other.corporation.name
    end
  end
end
