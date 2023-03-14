# frozen_string_literal: true

module Engine
  module Game
    module G1849
      class StockMarket < Engine::StockMarket
        attr_writer :game

        BLOCKED_RIGHT_PRICES = [218, 240, 276].freeze
        BLOCKED_UP_PRICES = [230].freeze

        def move(corp, coordinates, force: false)
          super
          return if corp.reached_max_value || !corp.share_price.end_game_trigger?

          @game.log << "#{corp.name} reached #{@game.format_currency(377)} share value,
                      game will end after it operates."
          corp.reached_max_value = true
          @game.max_value_reached = true
        end

        def right_ledge?(coordinates)
          r, c = coordinates
          price = @market.dig(r, c).price
          return false if BLOCKED_UP_PRICES.include?(price) && !@game.phase.status.include?('blue_zone')
          return true if BLOCKED_RIGHT_PRICES.include?(price) && !@game.phase.status.include?('blue_zone')

          super
        end

        def up(corporation, coordinates)
          price = share_price(coordinates).price
          return super if !BLOCKED_UP_PRICES.include?(price) || @game.phase.status.include?('blue_zone')

          @game.log << "#{corporation.name} share price blocked from moving up by phase"
          coordinates
        end

        def right(corporation, coordinates)
          price = share_price(coordinates).price
          return super if !BLOCKED_RIGHT_PRICES.include?(price) || @game.phase.status.include?('blue_zone')

          @game.log << "#{corporation.name} share price blocked from moving right by phase"
          coordinates
        end
      end
    end
  end
end
