# frozen_string_literal: true

module Engine
  class Token
    attr_reader :corporation, :logo, :type
    attr_accessor :city, :price, :used

    def initialize(corporation, price: 0, logo: nil, type: :normal)
      @corporation = corporation
      @price = price
      @logo = logo || corporation.logo
      @used = false
      @type = type
      @city = nil
    end

    def swap!(other_token)
      @city.tokens.map! { |t| t == self ? nil : t }
      corporation = other_token.corporation
      return unless @city.tokenable?(corporation, free: true)

      @city.place_token(corporation, other_token)
    end

    def move!(new_city)
      @city.tokens.map! { |t| t == self ? nil : t }

      new_city.place_token(@corporation, self, free: true)
    end
  end
end
