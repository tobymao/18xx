# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module GSteamOverHolland
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return [] unless can_entity_buy_train?(entity)
            return ['sell_shares'] if entity == current_entity&.owner && can_ebuy_sell_shares?(current_entity)

            return [] if entity != current_entity
            return %w[buy_train] if president_may_contribute?(entity)
            return %w[buy_train pass] if can_buy_train?(entity) || president_may_contribute?(entity)

            []
          end

          def pass_description
            if current_entity.trains.empty?
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
        end
      end
    end
  end
end
