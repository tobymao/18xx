# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G18CZ
      class BuySellParShares < BuySellParShares
        def actions(entity)
          return [] unless entity == current_entity

          actions = super

          actions << 'payoff_all_debt' if @game.debt(entity).positive?

          actions
        end

        def get_par_prices(entity, corp)
          @game.par_prices(corp).select { |p| p.price * 2 <= entity.cash }
        end

        def can_buy_any_from_market?(entity)
          super && @game.debt(entity).zero?
        end

        def process_payoff_all_debt(action)
          player = action.entity

          debt = @game.debt(player)

          player.spend(debt, @game.bank)
          @game.reset_debt(player)

          @log << "#{player.name} pays off #{@game.format_currency(debt)}"
        end

        def can_buy_any_from_ipo?(entity)
          super && @game.debt(entity).zero?
        end
      end
    end
  end
end
