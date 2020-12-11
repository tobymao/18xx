# frozen_string_literal: true

require_relative 'share_price'

module Engine
  class StockMarket
    attr_reader :market, :par_prices, :has_close_cell

    def initialize(market, unlimited_types, multiple_buy_types: [], zigzag: nil)
      @par_prices = []
      @has_close_cell = false
      @zigzag = zigzag
      @market = market.map.with_index do |row, r_index|
        row.map.with_index do |code, c_index|
          price = SharePrice.from_code(code,
                                       r_index,
                                       c_index,
                                       unlimited_types,
                                       multiple_buy_types: multiple_buy_types)
          @par_prices << price if price&.can_par?
          @has_close_cell = true if price&.type == :close
          price
        end
      end
      @par_prices.sort_by! do |p|
        r, c = p.coordinates
        [p.price, c, r]
      end.reverse!
    end

    def one_d?
      @one_d ||= @market.one?
    end

    def zigzag?
      !!@zigzag
    end

    def set_par(corporation, share_price)
      share_price.corporations << corporation
      corporation.share_price = share_price
      corporation.par_price = share_price
    end

    def move_right(corporation)
      r, c = corporation.share_price.coordinates

      if c + 1 < @market[r].size
        c += 1
        move(corporation, r, c)
      else
        move_up(corporation) unless one_d?
      end
    end

    def move_up(corporation)
      return move_right(corporation) if one_d?

      r, c = corporation.share_price.coordinates
      r -= 1 if r - 1 >= 0
      move(corporation, r, c)
    end

    def move_down(corporation)
      return move_left(corporation) if one_d?

      r, c = corporation.share_price.coordinates
      r += 1 if r + 1 < @market.size && share_price(r + 1, c)
      move(corporation, r, c)
    end

    def move_left(corporation)
      r, c = corporation.share_price.coordinates

      if c - 1 >= 0 && share_price(r, c - 1)
        c -= 1
        move(corporation, r, c)
      else
        move_down(corporation) unless one_d?
      end
    end

    def find_share_price(corporation, directions)
      find_relative_share_price(corporation.share_price, directions)
    end

    def find_relative_share_price(share, directions)
      r, c = share.coordinates

      prices = [share_price(r, c)]

      Array(directions).each do |direction|
        case direction
        when :left
          c -= 1 if c.positive?
        when :right
          c += 1
        when :down
          r -= 1 if r.positive?
        when :up
          r += 1
        end
        price = share_price(r, c)
        break unless price

        prices << price
      end
      prices.last
    end

    def max_reached?
      @max_reached
    end

    def move(corporation, row, column, force: false)
      share_price = share_price(row, column)
      return if share_price == corporation.share_price
      return if !force && !share_price.normal_movement?

      if corporation.max_share_price == corporation.share_price
        r, c = corporation.share_price.coordinates
        return if row > r || column > c
      end

      corporation.share_price.corporations.delete(corporation)
      corporation.share_price = share_price
      @max_reached = true if share_price.end_game_trigger?
      share_price.corporations << corporation
    end

    private

    def share_price(row, column)
      @market[row]&.[](column)
    end
  end
end
