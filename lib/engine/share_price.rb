# frozen_string_literal: true

module Engine
  class SharePrice
    attr_reader :coordinates, :price, :color, :corporations, :can_par, :end_game_trigger

    def self.from_code(code, row, column, unlimited_colors, multiple_buy_colors: [])
      return nil if !code || code == ''

      price = code.scan(/\d/).join('').to_i
      can_par = code.include?('p')
      end_game_trigger = code.include?('e')
      color =
        case
        when can_par
          :red
        when end_game_trigger
          :blue
        when code.include?('blk')
          :black
        when code.include?('b')
          :brown
        when code.include?('o')
          :orange
        when code.include?('y')
          :yellow
        end

      SharePrice.new([row, column],
                     price: price,
                     can_par: can_par,
                     end_game_trigger: end_game_trigger,
                     color: color,
                     unlimited_colors: unlimited_colors,
                     multiple_buy_colors: multiple_buy_colors)
    end

    def initialize(coordinates,
                   price:,
                   can_par: false,
                   end_game_trigger: false,
                   color: nil,
                   unlimited_colors: [],
                   multiple_buy_colors: [])
      @coordinates = coordinates
      @price = price
      @color = color
      @can_par = can_par
      @end_game_trigger = end_game_trigger
      @corporations = []
      @unlimited_colors = unlimited_colors
      @multiple_buy_colors = multiple_buy_colors
    end

    def id
      "#{@price},#{@coordinates.join(',')}"
    end

    def counts_for_limit
      !@unlimited_colors.include?(@color)
    end

    def buy_multiple?
      @multiple_buy_colors.include?(@color)
    end

    def to_s
      "#{self.class.name} - #{@price} #{@coordinates}"
    end
  end
end
