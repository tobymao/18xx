# frozen_string_literal: true

require_relative '../../../step/special_buy'

module Engine
  module Game
    module G1833NE
      module Step
        class SpecialBuy < Engine::Step::SpecialBuy
          def setup
            super
            @ferry_purchases = @game.class::FERRY_HEXES.to_h do |hex_id, info|
              name = info[:icon].split('_').map(&:capitalize).join(' ')
              [hex_id, Item.new(description: "#{name} (#{hex_id})", cost: @game.class::FERRY_COST)]
            end
          end

          def ferry_items
            @ferry_items ||= @game.class::FERRY_HEXES.to_h do |hex_id, info|
              name = info[:icon].split('_').map(&:capitalize).join(' ')
              [hex_id, Item.new(description: "#{name} (#{hex_id})", cost: @game.class::FERRY_COST)]
            end
          end

          def buyable_items(entity)
            return [] unless entity.corporation?

            ferry_items.filter_map do |hex_id, item|
              item if @game.can_buy_ferry?(entity, hex_id)
            end
          end

          def process_special_buy(action)
            pair = ferry_items.find { |_hex_id, item| item == action.item }
            raise GameError, "Cannot buy unknown item: #{action.item.description}" unless pair

            @game.buy_ferry(action.entity, pair.first)
          end

          def short_description
            'Ferry Tokens'
          end
        end
      end
    end
  end
end
