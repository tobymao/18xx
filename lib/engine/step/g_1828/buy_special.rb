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

        def items
          [{ :description => 'Coal Marker', :cost => 120}]
        end

        def process_buy_special(action)
          @game.buy_coal_marker(action.entity)
        end
      end
    end
  end
end
