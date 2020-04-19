# frozen_string_literal: true

module Engine
  class SharePrice
    attr_reader :coordinates, :price, :color, :corporations, :can_par

    def self.from_code(code, row, column, unlimited_colors)
      return nil if !code || code == ''

      price = code.scan(/\d/).join('').to_i
      can_par = code.include?('p')
      color =
        case
        when can_par
          :red
        when code.include?('b')
          :brown
        when code.include?('o')
          :orange
        when code.include?('y')
          :yellow
        end

      SharePrice.new([row, column], price: price, can_par: can_par, color: color, unlimited_colors: unlimited_colors)
    end

    def initialize(coordinates, price:, can_par: false, color: nil, unlimited_colors: [])
      @coordinates = coordinates
      @price = price
      @color = color
      @can_par = can_par
      @corporations = []
      @unlimited_colors = unlimited_colors
    end

    def id
      "#{@price},#{@coordinates.join(',')}"
    end

    def counts_for_cert_limit
      !@unlimited_colors.include?(@color)
    end
  end
end
