# frozen_string_literal: true

require_relative '../g_rolling_stock/game'
require_relative 'meta'
require_relative 'entities'

module Engine
  module Game
    module GRollingStockStars
      class Game < GRollingStock::Game
        include_meta(GRollingStockStars::Meta)
        include Entities

        PRESIDENT_SALES_TO_MARKET = true

        MARKET = [
          %w[0c
             5
             6
             7
             8
             9
             10
             11
             12
             13
             14
             16
             18
             20
             22
             24
             27
             30
             33
             37
             41
             45
             50
             55
             61
             68
             75e],
        ].freeze

        GAME_END_REASONS_TEXT = Base::GAME_END_REASONS_TEXT.merge(
          custom: 'Max stock price in phase 1 or 7 or end card flipped in phase 7',
        )

        PAR_PRICES = {
          1 => [10, 11, 12, 13, 14],
          2 => [10, 11, 12, 13, 14, 16, 18, 20],
          3 => [16, 18, 20, 22, 24, 27],
          4 => [22, 24, 27, 30, 33, 37],
          5 => [30, 33, 37],
        }.freeze

        COST_OF_OWNERSHIP = {
          1 => [0, 0, 0, 0, 0],
          2 => [0, 0, 0, 0, 0],
          3 => [0, 0, 0, 0, 0],
          4 => [2, 0, 0, 0, 0],
          5 => [4, 4, 0, 0, 0],
          7 => [7, 7, 7, 0, 0],
          8 => [10, 10, 10, 10, 0],
        }.freeze

        LEVEL_SYMBOLS = {
          1 => '★',
          2 => '★★',
          3 => '★★★',
          4 => '★★★★',
          5 => '★★★★★',
        }.freeze

        SEPARATE_WRAP_UP = false

        def rs_version
          2
        end

        def init_cost_table
          self.class::COST_OF_OWNERSHIP
        end

        def setup_preround
          @phase_counter = 0
        end

        def num_levels
          5
        end

        def synergy_value_by_level(company_a, company_b)
          level = @company_level[company_a]
          other_level = @company_level[company_b]
          case level
          when 1
            1
          when 2
            other_level < level ? 1 : 2
          when 3
            other_level < level ? 2 : 4
          when 4
            other_level < level ? 4 : 8
          else
            case other_level
            when 3
              4
            when 4
              8
            else
              16
            end
          end
        end

        def corporation_stars(corporation, cash = nil)
          total = ((cash || corporation.cash) / 10).to_i + corporation.companies.sum { |c| @company_level[c] }
          total += 2 if abilities(corporation, :stars)
          total
        end

        def target_stars(corporation)
          return 0 unless corporation.floated?

          (num_issued(corporation) * corporation.share_price.price / 10.0).round
        end

        def stars_change(corporation, cash = nil)
          current = corporation.share_price
          r, c = current.coordinates

          # assumes that current is not at either limit of market
          right = @stock_market.share_price([r, c + 1])
          left = @stock_market.share_price([r, c - 1])

          diff = corporation_stars(corporation, cash) - target_stars(corporation)
          diff = [[diff, 2].min, -2].max

          target = if diff > -2 && diff < 2
                     @stock_market.share_price([r, c + diff])
                   elsif diff == 2
                     right.end_game_trigger? ? right : @stock_market.share_price([r, c + 2])
                   else
                     left.price.zero? ? left : @stock_market.share_price([r, c - 2])
                   end

          actual = find_new_price(current, target, diff)

          [actual, target, diff]
        end

        def dividend_price_movement(corporation)
          new_price = stars_change(corporation)[0]

          move_to_price(corporation, new_price)
        end

        def dividend_help_str(entity, max)
          "Dividend per share. Range: From #{format_currency(0)}"\
            " to #{format_currency(max)}. Issued shares: #{num_issued(entity)}."\
            " Stars on share price: #{target_stars(entity)}★"
        end

        def dividend_chart(corporation)
          rows = (0..max_dividend_per_share(corporation)).map do |div|
            cash_left = corporation.cash - (div * num_issued(corporation))
            stars = corporation_stars(corporation, cash_left)
            price, target, diff = stars_change(corporation, cash_left)
            arrows = dividend_arrows(diff)
            target = "#{arrows} #{format_currency(target.price)}"
            price = format_currency(price.price)
            [format_currency(div), format_currency(cash_left), "#{stars}★", target, price]
          end
          [
            ['Div', 'Cash', 'Stars', 'Target Price', 'New Price'],
            *rows,
          ]
        end

        def share_card_description
          'Target Stars by Share Price'
        end

        def share_card_array(price)
          return [] if price.price.zero? || price.end_game_trigger?

          (2..7).map do |idx|
            [idx.to_s, "#{(idx * price.price / 10.0).round}★"]
          end
        end

        def movement_chart(corporation)
          stars = target_stars(corporation)
          price = corporation.share_price
          two_right = two_prices_to_right(price)&.price
          one_right = one_price_to_right(price)&.price
          one_left = one_price_to_left(price)&.price
          two_left = two_prices_to_left(price)&.price

          chart = [%w[Stars Price]]
          chart <<  ["#{stars + 2} ★", format_currency(two_right)] if two_right
          chart <<  ["#{stars + 1} ★", format_currency(one_right)] if one_right
          chart << ["#{[stars - 1, 0].max} ★", format_currency(one_left)] if one_left
          chart << ["#{[stars - 2, 0].max} ★", format_currency(two_left)] if two_left
          chart << ['', ''] while chart.size < 5
          chart
        end
      end
    end
  end
end
