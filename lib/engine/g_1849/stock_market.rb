# frozen_string_literal: true

require_relative 'stock_market'

module Engine
  module G1849
    class StockMarket < StockMarket
      attr_writer :game

      BLOCKED_RIGHT_PRICES = [218, 240, 276].freeze
      BLOCKED_UP_PRICES = [230].freeze

      def initialize(market, unlimited_types, multiple_buy_types: [])
        super
        @disabled_par_prices = @par_prices
        @par_prices = []
      end

      def enable_par_price(price)
        return unless (par = @disabled_par_prices.find { |p| p.price == price })

        @par_prices << par
        @disabled_par_prices.delete(par)
      end

      def move(corp, row, column, force: false)
        super
        return if corp.reached_max_value || !corp.share_price.end_game_trigger?

        @game.log << "#{corp.name} reached #{@game.format_currency(377)} share value,
                      game will end after it operates."
        corp.reached_max_value = true
        @game.max_value_reached = true
      end

      def move_up(corporation)
        price = corporation.share_price.price
        return super unless BLOCKED_UP_PRICES.include?(price) && !@game.phase.status.include?('blue_zone')

        @game.log << "#{corporation.name} share price blocked from moving up by phase"
      end

      def move_right(corporation)
        price = corporation.share_price.price
        return super unless BLOCKED_RIGHT_PRICES.include?(price) && !@game.phase.status.include?('blue_zone')

        @game.log << "#{corporation.name} share price blocked from moving right by phase"
        move_up(corporation)
      end
    end
  end
end
