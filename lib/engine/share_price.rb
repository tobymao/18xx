# frozen_string_literal: true

module Engine
  class SharePrice
    attr_reader :coordinates, :price, :corporations, :can_par, :type, :types

    TYPE_MAP = {
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
      'j' => :ignore_two_sales,
      's' => :safe_par,
      'P' => :par_overlap,
      'x' => :par_1,
      'z' => :par_2,
      'w' => :par_3,
      'C' => :convert_range,
      'm' => :max_price,
      'n' => :max_price_1,
      'u' => :phase_limited,
      'B' => :pays_bonus,
      'W' => :pays_bonus_1,
      'X' => :pays_bonus_2,
      'Y' => :pays_bonus_3,
      'Z' => :pays_bonus_4,
    }.freeze

    # Types which are info only and shouldn't
    NON_HIGHLIGHT_TYPES = %i[par safe_par par_1 par_2 par_3 par_overlap safe_par convert_range max_price max_price_1 repar].freeze

    # Types which count as par
    PAR_TYPES = %i[par par_overlap par_1 par_2 par_3].freeze

    def self.from_code(code, row, column, unlimited_types, multiple_buy_types: [])
      return nil if !code || code == ''

      m = code.match(/(\d*)([a-zA-Z]*)/)
      price = m[1].to_i

      types = []
      m[2].chars.each do |char|
        type = TYPE_MAP[char]
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

    def ==(other)
      @coordinates == other.coordinates
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
      PAR_TYPES.include?(@type)
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
      @type && !NON_HIGHLIGHT_TYPES.include?(@type)
    end

    def normal_movement?
      # Can be moved into normally, rather than something custom such as not owning a train.
      @type != :liquidation
    end

    def remove_par!
      @types -= PAR_TYPES
      @type = @types.first
    end
  end
end
