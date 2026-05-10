# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1880
      module Step
        class Route < Engine::Step::Route
          def actions(entity)
            return [] if !entity.operator? ||
            (entity.runnable_trains.empty? && !entity.minor?) ||
            (!@game.foreign_investors_operate && entity.minor?) ||
            !@game.can_run_route?(entity)

            ACTIONS
          end

          def process_run_routes(action)
            super

            bonus = @game.stock_market_bonus(action.entity)
            return unless bonus.positive?

            @round.extra_revenue = (@round.extra_revenue || 0) + bonus
            @log << "#{action.entity.name} receives an additional #{@game.format_currency(bonus)} stock market bonus"
          end
        end
      end
    end
  end
end
