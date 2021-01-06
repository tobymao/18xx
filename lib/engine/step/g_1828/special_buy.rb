# frozen_string_literal: true

require_relative '../special_buy'

module Engine
  module Step
    module G1828
      class SpecialBuy < SpecialBuy
        attr_reader :coal_marker
        def buyable_items(entity)
          @game.can_buy_coal_marker?(entity) ? [@coal_marker] : []
        end

        def short_description
          'Coal Marker'
        end

        def process_special_buy(action)
          item = action.item
          return @game.buy_coal_marker(action.entity) if item == @coal_marker

          raise GameError, "Cannot buy unknown item: #{item.description}"
        end

        def setup
          super
          @coal_marker ||= Item.new(description: 'Coal Marker', cost: 120)
        end
      end
    end
  end
end
