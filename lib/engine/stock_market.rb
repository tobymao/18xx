# frozen_string_literal: true

require_relative 'share_price'
require_relative 'stock_movement'

module Engine
  class StockMarket
    attr_reader :market, :par_prices, :has_close_cell, :zigzag

    def initialize(market, unlimited_types, multiple_buy_types: [], zigzag: nil, ledge_movement: nil, hex_market: nil)
      @par_prices = []
      @has_close_cell = false
      @zigzag = zigzag
      @hex_market = hex_market
      @market = if @hex_market
                  hex_market_init(market, unlimited_types, multiple_buy_types)
                else
                  orthogonal_market_init(market, unlimited_types, multiple_buy_types)
                end
      # note, a lot of behavior depends on the par prices being in descending price order
      @par_prices.sort_by! do |p|
        r, c = p.coordinates
        [p.price, c, r]
      end.reverse!

      @movement =
        if @hex_market
          HexMovement.new(self)
        elsif @zigzag
          ZigZagMovement.new(self, ledge_movement)
        elsif one_d?
          OneDimensionalMovement.new(self)
        else
          TwoDimensionalMovement.new(self)
        end
    end

    def orthogonal_market_init(market, unlimited_types, multiple_buy_types)
      market.map.with_index do |row, r_index|
        row.map.with_index do |code, c_index|
          price = if code.instance_of?(Hash)
                    SharePrice.new([r_index, c_index], unlimited_types: unlimited_types, multiple_buy_types: multiple_buy_types,
                                                       **code)
                  else
                    SharePrice.from_code(code,
                                         r_index,
                                         c_index,
                                         unlimited_types,
                                         multiple_buy_types: multiple_buy_types)
                  end
          @par_prices << price if price&.can_par?
          @has_close_cell = true if price&.type == :close
          price
        end
      end
    end

    def hex_market_init(market, unlimited_types, multiple_buy_types)
      # rows are defined as lists, same as 2D.
      # assumption: the first two items in rows 0 and 1
      # are offset such that row 0, col 0 is above and to the left of
      # row 1, col 0.  rows then alternate in the hex pattern
      # TODO: this is hard-coded to the 1854 market, where the hexes align this way based on the number of rows
      # TODO: could be more configurable.
      new_market = []
      market.each_with_index do |row, r_index|
        new_row = []
        row.each_with_index do |code, c_index|
          new_c_index = if r_index.odd?
                          c_index * 2
                        else
                          (c_index * 2) + 1
                        end

          price = if code.instance_of?(Hash)
                    SharePrice.new(
                      [r_index, new_c_index],
                      unlimited_types: unlimited_types,
                      multiple_buy_types: multiple_buy_types,
                      **code
                    )
                  else
                    SharePrice.from_code(code,
                                         r_index,
                                         new_c_index,
                                         unlimited_types,
                                         multiple_buy_types: multiple_buy_types)
                  end
          @par_prices << price if price&.can_par?
          @has_close_cell = true if price&.type == :close
          if new_c_index.positive?
            new_row << SharePrice.from_code('', r_index, new_c_index - 1, unlimited_types, multiple_buy_types: multiple_buy_types)
          end
          new_row << price
        end
        new_market << new_row
      end
      new_market
    end

    def hex_market?
      !@hex_market.nil?
    end

    def one_d?
      @one_d ||= @market.one?
    end

    def set_par(corporation, share_price)
      share_price.corporations << corporation
      corporation.share_price = share_price
      corporation.par_price = share_price
      corporation.original_par_price = share_price
    end

    def right_ledge?(coordinates)
      row, col = coordinates
      col + 1 == @market[row].size
    end

    def move_right(corporation)
      move(corporation, right(corporation, corporation.share_price.coordinates))
    end

    def right(corporation, coordinates)
      @movement.right(corporation, coordinates)
    end

    def move_up(corporation)
      move(corporation, up(corporation, corporation.share_price.coordinates))
    end

    def up(corporation, coordinates)
      @movement.up(corporation, coordinates)
    end

    def move_down(corporation)
      move(corporation, down(corporation, corporation.share_price.coordinates))
    end

    def down(corporation, coordinates)
      @movement.down(corporation, coordinates)
    end

    def move_left(corporation)
      move(corporation, left(corporation, corporation.share_price.coordinates))
    end

    def left(corporation, coordinates)
      @movement.left(corporation, coordinates)
    end

    def move_up_left_hex(corporation)
      move(corporation, up_left_hex(corporation, corporation.share_price.coordinates))
    end

    def up_left_hex(corporation, coordinates)
      @movement.up_left_hex(corporation, coordinates)
    end

    def move_down_left_hex(corporation)
      move(corporation, down_left_hex(corporation, corporation.share_price.coordinates))
    end

    def down_left_hex(corporation, coordinates)
      @movement.down_left_hex(corporation, coordinates)
    end

    def move_up_right_hex(corporation)
      move(corporation, up_right_hex(corporation, corporation.share_price.coordinates))
    end

    def up_right_hex(corporation, coordinates)
      @movement.up_right_hex(corporation, coordinates)
    end

    def move_down_right_hex(corporation)
      move(corporation, down_right_hex(corporation, corporation.share_price.coordinates))
    end

    def down_right_hex(corporation, coordinates)
      @movement.down_right_hex(corporation, coordinates)
    end

    def find_share_price(corporation, directions)
      find_relative_share_price(corporation.share_price, corporation, directions)
    end

    def find_relative_share_price(share, corporation, directions)
      coordinates = share.coordinates

      price = share_price(coordinates)

      Array(directions).each do |direction|
        case direction
        when :left
          coordinates = left(corporation, coordinates)
        when :right
          coordinates = right(corporation, coordinates)
        when :down
          coordinates = down(corporation, coordinates)
        when :up
          coordinates = up(corporation, coordinates)
        end
        price = share_price(coordinates) || price
      end
      price
    end

    def max_reached?
      @max_reached
    end

    def move(corporation, coordinates, force: false)
      share_price = share_price(coordinates)
      return unless share_price
      return if share_price == corporation.share_price
      return if !force && !share_price.normal_movement?

      corporation.share_price.corporations.delete(corporation)
      corporation.share_price = share_price
      @max_reached = true if share_price.end_game_trigger?
      share_price.corporations << corporation
    end

    def share_prices_with_types(types)
      # Find prices which types includes one of the types passed in
      @market.flat_map { |m| m.select { |sp| sp && (types & sp&.types).any? } }
      .sort_by(&:price)
      .reverse
    end

    def share_price(coordinates)
      row, column = coordinates
      @market[row]&.[](column)
    end

    def remove_par!(price)
      @par_prices.delete(price)
      price.remove_par!
    end
  end
end
