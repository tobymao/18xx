# frozen_string_literal: true

require_relative 'share_price'

module Engine
  class StockMarket
    attr_reader :market, :par_prices

    def initialize(market, unlimited_colors)
      @par_prices = []
      @market = market.map.with_index do |row, r_index|
        row.map.with_index do |code, c_index|
          price = SharePrice.from_code(code, r_index, c_index, unlimited_colors)
          @par_prices << price if price&.can_par
          price
        end
      end
    end

    def set_par(corporation, share_price)
      share_price.corporations << corporation
      corporation.share_price = share_price
      corporation.par_price = share_price
    end

    def move_right(corporation, jumps)
      r, c = corporation.share_price.coordinates
      jumps.times do
        if c + 1 < @market[r].size
          c += 1
          move(corporation, r, c)
        else
          move_up(corporation)
        end
      end
    end

    def move_up(corporation)
      r, c = corporation.share_price.coordinates
      r -= 1 if r - 1 >= 0
      move(corporation, r, c)
    end

    def move_down(corporation)
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
        move_down(corporation)
      end
    end

    def find_share_price(corporation, direction)
      r, c = corporation.share_price.coordinates
      case direction
      when :left
        c -= 1
        share_price(r, c) || share_price(r, c + 1)
      when :right
        c += 1
        share_price(r, c) || share_price(r, c - 1)
      when :down
        r -= 1
        share_price(r, c) || share_price(r + 1, c)
      when :up
        r += 1
        share_price(r, c) || share_price(r - 1, c)
      end
    end

    private

    def share_price(row, column)
      @market[row]&.[](column)
    end

    def move(corporation, row, column)
      share_price = share_price(row, column)
      return if share_price == corporation.share_price

      corporation.share_price.corporations.delete(corporation)
      corporation.share_price = share_price
      share_price.corporations << corporation
    end
  end
end
