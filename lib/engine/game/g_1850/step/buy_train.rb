# frozen_string_literal: true

require_relative '../../g_1870/step/buy_train'

module Engine
  module Game
    module G1850
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def round_state
            super.merge(
            {
              bought_trains: [],
            }
          )
          end

          def process_buy_train(action)
            from_depot = action.train.from_depot?
            super
            return unless from_depot

            entity = action.entity
            @round.bought_trains << entity
            pass! unless buyable_trains(entity).any?
          end

          def buyable_trains(entity)
            trains = super.dup
            trains.reject!(&:from_depot?) if @round.bought_trains.include?(entity)
            trains
          end

          def can_buy_train?(entity = nil, _shell = nil)
            super && !buyable_trains(entity).empty?
          end
        end
      end
    end
  end
end
