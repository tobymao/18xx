# frozen_string_literal: true

require_relative '../../../step/special_buy'

module Engine
  module Game
    module G1894
      module Step
        class SpecialBuy < Engine::Step::SpecialBuy
          attr_reader :ferry_marker

          def buyable_items(entity)
            return [@ferry_marker] if @game.loading || @game.can_buy_ferry_marker?(entity)

            []
          end

          def short_description
            'Ferry marker'
          end

          def process_special_buy(action)
            raise GameError, "Cannot buy unknown item: #{item.description}" if action.item != @ferry_marker
            if !@game.loading && !@game.can_buy_ferry_marker?(action.entity)
              raise GameError, 'Must be connected to England to purchase'
            end

            @game.buy_ferry_marker(action.entity)
          end

          def setup
            super
            @ferry_marker ||= Item.new(description: 'Ferry marker', cost: 60)
          end
        end
      end
    end
  end
end
