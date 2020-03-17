# frozen_string_literal: true

module Engine
  class SharePrice
    attr_reader :coordinates, :price, :color, :corporations, :can_par

    def self.from_code(code, row, column)
      return nil if !code || code == ''

      price = code.scan(/\d/).join('').to_i
      can_par = code.include?('p')
      color =
        case
        when code.include?('b')
          :brown
        when code.include?('o')
          :orange
        when code.include?('y')
          :yellow
        end

      SharePrice.new([row, column], price: price, can_par: can_par, color: color)
    end

    def initialize(coordinates, price:, can_par: false, color: nil)
      @coordinates = coordinates
      @price = price
      @color = color
      @can_par = can_par
      @corporations = []
    end

    def id
      "#{@price}-#{@coordinates}"
    end
  end
end
