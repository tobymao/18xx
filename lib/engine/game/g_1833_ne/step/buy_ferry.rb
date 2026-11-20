# frozen_string_literal: true

require_relative '../../../step/special_buy'
require_relative 'receivership_skip'

module Engine
  module Game
    module G1833NE
      module Step
        class BuyFerry < Engine::Step::SpecialBuy
          include ReceivershipSkip

          def buyable_items(entity)
            return [] unless entity.corporation?

            @game.buyable_ferries(entity).map { |hex| ferry_item(hex) }
          end

          def process_special_buy(action)
            entity = action.entity
            hex = @game.ferry_hexes.find { |ferry_hex| ferry_item(ferry_hex) == action.item }
            if !hex || (!@game.loading && !@game.buyable_ferries(entity).include?(hex))
              raise GameError, "#{entity.name} cannot buy #{action.item.description}"
            end

            @game.buy_ferry!(entity, hex)
            pass!
          end

          def description
            'Buy Ferry'
          end

          def short_description
            'Ferry'
          end

          private

          def ferry_item(hex)
            Item.new(description: "#{@game.ferry_name(hex)} (#{hex.id})", cost: @game.ferry_cost)
          end
        end
      end
    end
  end
end
