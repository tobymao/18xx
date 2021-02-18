# frozen_string_literal: true

require_relative '../../../step/special_buy'

module Engine
  module Game
    module G1828
      module Step
        class SpecialBuy < Engine::Step::SpecialBuy
          attr_reader :coal_marker

          def buyable_items(entity)
            return [@coal_marker] if @game.loading || @game.can_buy_coal_marker?(entity)

            []
          end

          def short_description
            'Coal Marker'
          end

          def process_special_buy(action)
            raise GameError, "Cannot buy unknown item: #{item.description}" if action.item != @coal_marker
            if !@game.loading && !@game.can_buy_coal_marker?(action.entity)
              raise GameError, 'Must be connected to Virigina Coalfields to purchase'
            end

            @game.buy_coal_marker(action.entity)
          end

          def setup
            super
            @coal_marker ||= Item.new(description: 'Coal Marker', cost: 120)
          end
        end
      end
    end
  end
end
