# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18EU
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          # This is necessary because base code assumes minors cannot purchase trains.
          # That shouldn't be base, imo, but requires a refactor.
          def actions(entity)
            return ['sell_shares'] if entity == current_entity.owner

            return [] if entity != current_entity

            return %w[sell_shares buy_train] if president_may_contribute?(entity)
            return %w[buy_train pass] if can_buy_train?(entity)

            []
          end

          def buyable_trains(entity)
            trains = super

            trains.reject! do |t|
              @game.pullman?(t) &&
                (entity.trains.empty? ||
                  @game.owns_pullman?(entity) ||
                  t.owner.corporation?)
            end

            trains
          end
        end
      end
    end
  end
end
