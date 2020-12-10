# frozen_string_literal: true

module Engine
  class SharePrice
    attr_reader :coordinates, :price, :corporations, :can_par, :type, :types

    def self.from_code(code, row, column, unlimited_types, multiple_buy_types: [])
      return nil if !code || code == ''

      m = code.match(/(\d*)([a-zA-Z]*)/)
      price = m[1].to_i

      types = []
      m[2].chars.each do |char|
        type_map = {
          'p' => :par,
          'e' => :endgame,
          'c' => :close,
          'b' => :multiple_buy,
          'o' => :unlimited,
          'y' => :no_cert_limit,
          'l' => :liquidation,
          'a' => :acquisition,
          'r' => :repar,
          'i' => :ignore_one_sale,
          's' => :safe_par,
          'x' => :par_1,
          'z' => :par_2,
          'C' => :convert_range,
          'm' => :max_price,
        }.freeze
        type = type_map[char]
        types << type
      end

      SharePrice.new([row, column],
                     price: price,
                     types: types,
                     unlimited_types: unlimited_types,
                     multiple_buy_types: multiple_buy_types)
    end

    def initialize(coordinates,
                   price:,
                   types: [],
                   unlimited_types: [],
                   multiple_buy_types: [])
      @coordinates = coordinates
      @price = price
      @type = types&.first
      @types = types
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

    def highlight?
      # Should it be highlighted in corporation/spreadsheet UI
      @type && !%i[par safe_par].include?(@type)
    end

    def normal_movement?
      # Can be moved into normally, rather than something custom such as not owning a train.
      @type != :liquidation
    end
  end
end
