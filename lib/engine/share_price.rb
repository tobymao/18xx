# frozen_string_literal: true

module Engine
  class SharePrice
    attr_reader :coordinates, :price, :corporations, :can_par, :type

    def self.from_code(code, row, column, unlimited_types, multiple_buy_types: [])
      return nil if !code || code == ''

      price = code.scan(/\d/).join('').to_i

      type =
        case code
        when /p/
          :par
        when /e/
          :endgame
        when /c/
          :close
        when /b/
          :multiple_buy
        when /o/
          :unlimited
        when /y/
          :no_cert_limit
        when /l/
          :liquidation
        when /a/
          :acquisition
        when /r/
          :repar
        when /i/
          :ignore_one_sale
        when /s/
          :safe_par
        end

      SharePrice.new([row, column],
                     price: price,
                     type: type,
                     unlimited_types: unlimited_types,
                     multiple_buy_types: multiple_buy_types)
    end

    def initialize(coordinates,
                   price:,
                   type: nil,
                   unlimited_types: [],
                   multiple_buy_types: [])
      @coordinates = coordinates
      @price = price
      @type = type
      @corporations = []
      @can_buy_multiple = multiple_buy_types.include?(type)
      @limited = !unlimited_types.include?(type)
    end

    def id
      "#{@price},#{@coordinates.join(',')}"
    end

    def counts_for_limit
      @limited
    end

    def buy_multiple?
      @can_buy_multiple
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
