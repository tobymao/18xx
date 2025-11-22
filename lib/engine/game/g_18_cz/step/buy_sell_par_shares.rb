# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18CZ
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def actions(entity)
            return [] unless entity == current_entity

            actions = super

            actions << 'special_buy' if entity.debt.positive?

            actions << 'pass' if !actions.include?('pass') && !actions.empty?

            actions
          end

          def get_par_prices(entity, corp)
            @game.par_prices(corp).select { |p| p.price * 2 <= entity.cash }
          end

          def can_buy_any_from_market?(entity)
            super && entity.debt.zero?
          end

          def process_special_buy(action)
            player = action.entity

            debt = player.debt
            player.repay_cash_loan(@game.bank)
            @log << "#{player.name} pays off #{@game.format_currency(debt)}"
          end

          def can_buy_any_from_ipo?(entity)
            super && entity.debt.zero?
          end

          def buyable_items(entity)
            [Item.new(description: 'Payoff all debt', cost: entity.debt)]
          end

          def item_str(item)
            "#{item.description} (#{@game.format_currency(item.cost)})"
          end

          def override_entities
            @game.exclude_vaclav(@round.entities)
          end
        end
      end
    end
  end
end
