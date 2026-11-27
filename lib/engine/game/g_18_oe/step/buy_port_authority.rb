# frozen_string_literal: true

require_relative '../../../step/special_buy'

module Engine
  module Game
    module G18OE
      module Step
        class BuyPortAuthority < Engine::Step::SpecialBuy
          def setup
            super
            @items ||= @game.port_authority_seas.to_h do |sea|
              [sea, Item.new(description: @game.port_authority_name(sea), cost: @game.port_authority_cost)]
            end
          end

          def buyable_items(entity)
            return [] unless entity == @round.current_operator

            @items.select { |sea, _item| @game.can_buy_port_authority?(entity, sea) }.values
          end

          def item_str(item)
            sea = @items.key(item)
            "Buy #{item.description} (#{@game.format_currency(item.cost)}, #{@game.port_authorities_left(sea)} left)"
          end

          def short_description
            'Port Authority'
          end

          def process_special_buy(action)
            sea, = @items.find { |_sea, item| item == action.item }
            raise GameError, "Cannot buy unknown item: #{action.item.description}" unless sea
            raise GameError, "Cannot buy #{action.item.description}" unless @game.can_buy_port_authority?(action.entity, sea)

            @game.buy_port_authority!(action.entity, sea)
          end
        end
      end
    end
  end
end
