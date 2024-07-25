# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module GSteamOverHolland
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return ['sell_shares'] if entity == current_entity&.owner && can_ebuy_sell_shares?(current_entity)

            return [] if entity != current_entity
            return %w[sell_shares buy_train pass] if president_may_contribute?(entity)
            return %w[buy_train pass] if can_buy_train?(entity)

            []
          end

          def pass_description
            if can_close_corp?(current_entity)
              "Close #{current_entity.name}"
            else
              @acted ? 'Done (Trains)' : 'Skip (Trains)'
            end
          end

          def process_pass(action)
            entity = action.entity
            return super unless entity.trains.empty?

            @game.close_corporation(entity)
          end

          def must_sell_shares?(corporation)
            return false if corporation.cash >= @game.depot.min_depot_price || !corporation.trains.empty?

            can_issue?(corporation)
          end

          def can_issue?(corporation)
            return false unless corporation.corporation?
            return false if @game.issued_shares

            @game.issuable_shares(corporation).any?
          end

          def should_buy_train?(entity)
            :close_corp if can_close_corp?(entity)
          end

          def can_close_corp?(entity)
            entity.trains.empty? &&
              !can_issue?(entity) &&
              entity.cash + entity.owner.cash < @game.depot.min_depot_price &&
              @game.graph.route_info(entity)&.dig(:route_train_purchase)
          end

          def can_buy_needed_train?(entity)
            entity.trains.empty? &&
              entity.cash + entity.owner.cash >= @game.depot.min_depot_price &&
              @game.graph.route_info(entity)&.dig(:route_train_purchase)
          end
        end
      end
    end
  end
end
