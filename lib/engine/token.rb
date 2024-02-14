# frozen_string_literal: true

module Engine
  class Token
    attr_reader :extra, :cheater
    attr_accessor :city, :price, :type, :used, :status, :hex, :corporation, :logo, :simple_logo

    def initialize(corporation, price: 0, logo: nil, simple_logo: nil, type: :normal)
      @corporation = corporation
      @price = price
      @logo = logo || corporation.logo
      @simple_logo = simple_logo || corporation&.simple_logo || @logo
      @used = false
      @extra = nil # Is this in an extra slot? (bull token)
      @cheater = nil
      @type = type
      @city = nil
      @hex = nil
      @status = nil
      @location_type = nil
    end

    def destroy!
      @corporation.tokens.delete(self)
      remove!
    end

    def remove!
      case @location_type
      when :city
        @city&.tokens&.map! { |t| t == self ? nil : t }
        @city&.extra_tokens&.delete(self)
      when :hex
        @hex.remove_token(self)
      end
      @city = nil
      @hex = nil
      @used = false
      @extra = false
      @cheater = false
      @location_type = nil
    end

    def swap!(other_token, check_tokenable: true, free: true)
      city = @city
      hex = @hex
      extra = @extra
      location_type = @location_type
      remove!
      corporation = other_token.corporation

      return if !extra && check_tokenable && location_type == :city && !city.tokenable?(corporation, free: free,
                                                                                                     tokens: [other_token])

      case location_type
      when :city
        city.place_token(corporation, other_token, free: free, check_tokenable: check_tokenable, extra_slot: extra)
      when :hex
        hex.place_token(other_token)
      end
    end

    def move!(new_location)
      remove!

      case new_location
      when Engine::Part::City
        new_location.place_token(@corporation, self, free: true)
      when Engine::Part::Hex
        new_location.place_token(self)
      end
    end

    def place(location, extra: nil, cheater: nil)
      @used = true
      case location
      when Engine::Part::City
        @location_type = :city
        @city = location
        @hex = location&.hex
      when Engine::Hex
        @location_type = :hex
        @hex = location
      end
      @extra = extra
      @cheater = cheater
    end

    def inspect
      if @hex
        location =
          if @hex.id == @hex.tile.name
            [@hex.id, @city.index, @city.tokens.index(self)]
          else
            [@hex.id, @hex.tile.name, @city.index, @city.tokens.index(self) || '?']
          end
        "<#{self.class.name}: corp:#{corporation.name}, #{location.join('-')}>"
      else
        "<#{self.class.name}: corp:#{corporation.name}, price:#{@price}>"
      end
    end
  end
end
