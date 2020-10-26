# frozen_string_literal: true

module Engine
  class SharePrice
    attr_reader :coordinates, :price, :color, :corporations, :can_par, :type

    def self.from_code(code, row, column, unlimited_colors, multiple_buy_colors: [])
      return nil if !code || code == ''

      price = code.scan(/\d/).join('').to_i

      color, type =
        case code
        when /p/
          %i[red par]
        when /e/
          %i[blue endgame]
        when /c/
          %i[black close]
        when /b/
          %i[brown multiple_buy]
        when /o/
          %i[orange unlimited]
        when /y/
          %i[yellow no_cert_limit]
        when /l/
          %i[red liquidation]
        when /a/
          %i[gray acquisition]
        when /r/
          %i[gray repar]
        when /i/
          %i[green ignore_one_sale]
        when /s/
          %i[white safe_par]
        end

      SharePrice.new([row, column],
                     price: price,
                     color: color,
                     type: type,
                     unlimited_colors: unlimited_colors,
                     multiple_buy_colors: multiple_buy_colors)
    end

    def initialize(coordinates,
                   price:,
                   color: nil,
                   type: nil,
                   unlimited_colors: [],
                   multiple_buy_colors: [])
      @coordinates = coordinates
      @price = price
      @color = color
      @type = type
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

    def can_par?
      @type == :par
    end

    def end_game_trigger?
      @type == :endgame
    end

    def liquidation?
      @type == :liquidation
    end

    def acquisition?
      @type == :acquisition
    end

    def normal_movement?
      # Can be moved into normally, rather than something custom such as not owning a train.
      @type != :liquidation
    end
  end
end
