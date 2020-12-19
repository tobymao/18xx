# frozen_string_literal: true

module Engine
  class Token
    attr_reader :corporation, :logo
    attr_accessor :city, :price, :type, :used, :status

    def initialize(corporation, price: 0, logo: nil, type: :normal)
      @corporation = corporation
      @price = price
      @logo = logo || corporation.logo
      @used = false
      @type = type
      @city = nil
      @status = nil
    end

    def destroy!
      @corporation.tokens.delete(self)
      @city.tokens.map! { |t| t == self ? nil : t }
    end

    def remove!
      @city&.tokens&.map! { |t| t == self ? nil : t }
      @city = nil
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

    def place(city)
      @used = true
      @city = city
    end
  end
end
