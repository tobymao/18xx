# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1829
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def actions(entity)
            return [] unless entity == current_entity

            actions = super

            actions << 'pass' unless actions.include?('pass') || actions.empty?

            actions
          end

          def get_par_prices(entity, corp)
            @game.par_prices(corp).select { |p| p.price * 2 <= entity.cash }
          end

          def can_buy_any_from_market?(entity)
            super && @game.debt(entity).zero?
          end

          def item_str(item)
            "#{item.description} (#{@game.format_currency(item.cost)})"
          end
        end
      end
    end
  end
end
