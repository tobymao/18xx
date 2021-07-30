# frozen_string_literal: true

module Engine
  class Token
    attr_reader :logo, :simple_logo, :extra
    attr_accessor :city, :price, :type, :used, :status, :hex, :corporation

    def initialize(corporation, price: 0, logo: nil, simple_logo: nil, type: :normal)
      @corporation = corporation
      @price = price
      @logo = logo || corporation.logo
      @simple_logo = simple_logo || corporation&.simple_logo || @logo
      @used = false
      @extra = nil # Is this in an extra slot? (bull token)
      @type = type
      @city = nil
      @hex = nil
      @status = nil
    end

    def destroy!
      @corporation.tokens.delete(self)
      remove!
    end

    def remove!
      @city&.tokens&.map! { |t| t == self ? nil : t }
      @city&.extra_tokens&.delete(self)
      @city = nil
      @hex = nil
      @used = false
      @extra = false
    end

    def swap!(other_token, check_tokenable: true, free: true)
      city = @city
      extra = @extra
      remove!
      corporation = other_token.corporation

      return if !extra && check_tokenable && !city.tokenable?(corporation, free: free, tokens: [other_token])

      city.place_token(corporation, other_token, free: free, check_tokenable: check_tokenable, extra_slot: extra)
    end

    def move!(new_city)
      remove!

      new_city.place_token(@corporation, self, free: true)
    end

    def place(city, hex: nil, extra: nil)
      @used = true
      @city = city
      @hex = hex || city.hex
      @extra = extra
    end
  end
end
