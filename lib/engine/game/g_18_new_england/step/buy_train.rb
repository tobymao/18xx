# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18NewEngland
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return [] unless can_entity_buy_train?(entity)

            return ['sell_shares'] if entity == current_entity.owner && president_may_contribute?(current_entity)

            return [] if entity != current_entity

            # minor companies can be closed when forced to buy trains (closure is processed as pass action)
            return %w[buy_train] if entity.type != :minor && must_buy_train?(entity)
            return %w[pass buy_train] if can_buy_train?(entity)

            []
          end

          def pass_description
            if current_entity.trains.empty? && current_entity.type == :minor
              "Close #{current_entity.name}"
            else
              @acted ? 'Done (Trains)' : 'Skip (Trains)'
            end
          end

          def process_pass(action)
            entity = action.entity
            return super unless entity.trains.empty? && entity.type == :minor

            @game.close_corporation(entity)
          end
        end
      end
    end
  end
end
