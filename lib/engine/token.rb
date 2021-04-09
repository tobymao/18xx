# frozen_string_literal: true

module Engine
  class Token
    attr_reader :corporation, :logo, :simple_logo
    attr_accessor :city, :price, :type, :used, :status, :hex

    def initialize(corporation, price: 0, logo: nil, simple_logo: nil, type: :normal)
      @corporation = corporation
      @price = price
      @logo = logo || corporation.logo
      @simple_logo = simple_logo || corporation&.simple_logo || @logo
      @used = false
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
      @city = nil
      @hex = nil
      @used = false
    end

    def swap!(other_token, check_tokenable: true)
      city = @city
      remove!
      corporation = other_token.corporation
      return if check_tokenable && !city.tokenable?(corporation, free: true, tokens: [other_token])

      city.place_token(corporation, other_token, check_tokenable: check_tokenable)
    end

    def move!(new_city)
      remove!

      new_city.place_token(@corporation, self, free: true)
    end

    def place(city, hex: nil)
      @used = true
      @city = city
      @hex = hex || city.hex
    end
  end
end
