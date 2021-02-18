# frozen_string_literal: true

require_relative '../../../step/special_buy'

module Engine
  module Game
    module G1856
      module Step
        class SpecialBuy < Engine::Step::SpecialBuy
          attr_reader :tunnel_item, :bridge_item

          def buyable_items(entity)
            items = []
            items << @tunnel_item if @game.can_buy_tunnel_token?(entity)
            items << @bridge_item if @game.can_buy_bridge_token?(entity)
            items
          end

          def short_description
            'Tunnel & Bridge Tokens'
          end

          def process_special_buy(action)
            item = action.item
            return @game.buy_tunnel_token(action.entity) if item == @tunnel_item
            return @game.buy_bridge_token(action.entity) if item == @bridge_item

            raise GameError, "Cannot buy unknown item: #{item.description}"
          end

          def setup
            super
            @tunnel_item ||= Item.new(description: 'Tunnel Token', cost: 50)
            @bridge_item ||= Item.new(description: 'Bridge Token', cost: 50)
          end
        end
      end
    end
  end
end
