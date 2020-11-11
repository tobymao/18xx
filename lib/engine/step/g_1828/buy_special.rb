# frozen_string_literal: true

require_relative '../buy_special'

module Engine
  module Step
    module G1828
      class BuySpecial < BuySpecial
        def can_buy_special?(entity)
          @game.can_buy_coal_marker?(entity)
        end

        def short_description
          'Coal Marker'
        end

        def process_buy_special(action)
          item = action.item
          @game.game_error("Cannot buy unknown item: #{item.description}") if item != @items.first

          @game.buy_coal_marker(action.entity)
        end

        def setup
          super
          @items << Item.new(description: 'Coal Marker', cost: 120)
        end
      end
    end
  end
end
