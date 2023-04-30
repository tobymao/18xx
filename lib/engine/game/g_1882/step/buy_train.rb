# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1882
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return %w[sell_shares] if entity == current_entity&.owner && can_ebuy_sell_shares?(current_entity)

            return [] if entity != current_entity
            return %w[buy_train] if must_buy_train?(entity)
            return %w[buy_train pass] if can_buy_train?(entity)

            []
          end

          def president_may_contribute?(entity, _shell = nil)
            entity.trains.empty? &&
              (@game.graph.route_info(entity)&.dig(:route_train_purchase) ||
               @game.graph.reachable_hexes(entity).include?(@game.fishing_exit))
          end
        end
      end
    end
  end
end
