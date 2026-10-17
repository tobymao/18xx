# frozen_string_literal: true

require_relative '../../g_1861/step/skip_for_national'
require_relative '../../g_1867/step/buy_train'

module Engine
  module Game
    module G1864
      module Step
        class BuyTrain < G1867::Step::BuyTrain
          include G1861::SkipForNational

          def room?(entity, _shell = nil)
            train_room?(entity) || other_trains(entity).any? { |train| @game.pullman?(train) }
          end

          def train_room?(entity)
            @game.num_corp_trains(entity) < @game.train_limit(entity)
          end

          def buyable_trains(entity)
            trains = super
            trains = trains.select { |train| @game.pullman?(train) } unless train_room?(entity)
            trains.select { |train| !@game.pullman?(train) || entity.cash.positive? }
          end

          def spend_minmax(entity, train)
            return [1, entity.cash] if @game.pullman?(train)

            super
          end

          def process_buy_train(action)
            entity = action.entity
            if !@game.pullman?(action.train) && !train_room?(entity)
              raise GameError, "#{entity.name} has no room for another train"
            end

            super
          end
        end
      end
    end
  end
end
