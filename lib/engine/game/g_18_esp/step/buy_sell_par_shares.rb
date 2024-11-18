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
            actions << 'payoff_player_debt' if @game.player_debt(entity).positive? && can_fully_payoff?(entity)

            actions
          end

          def can_fully_payoff?(entity)
            total_owed = @game.player_debt(entity) + @game.player_interest(entity)
            entity.cash >= total_owed
          end

          def process_payoff_player_debt(action)
            player = action.entity
            @game.payoff_player_loan(player)
            track_action(action, player)
          end

          def can_buy_any?(entity)
            @game.player_debt(entity).zero? && super
          end

          def can_ipo_any?(entity)
            @game.player_debt(entity).zero? && super
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
