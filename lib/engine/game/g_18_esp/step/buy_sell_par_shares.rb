# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18ESP
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def actions(entity)
            return [] unless entity == current_entity

            actions = super
            actions << 'payoff_player_debt' if entity.debt.positive? && can_fully_payoff?(entity)

            actions
          end

          def can_fully_payoff?(entity)
            entity.cash >= entity.debt
          end

          def process_payoff_player_debt(action)
            player = action.entity
            @game.payoff_player_loan(player)
            track_action(action, player)
          end

          def can_buy_any?(entity)
            entity.debt.zero? && super
          end

          def can_ipo_any?(entity)
            entity.debt.zero? && super
          end

          def visible_corporations
            @game.sorted_corporations
          end

          def get_par_prices(_entity, corp)
            super.reject do |p|
              p.price == 100 || p.price == 95 if !@game.phase.status.include?('higher_par_prices') && @game.north_corp?(corp)
            end
          end
        end
      end
    end
  end
end
