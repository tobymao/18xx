# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18OE
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def can_entity_buy_train?(entity)
            entity.corporation?
          end

          def must_buy_train?(entity)
            return false if @game.fulfilled_train_obligation.include?(entity.id)
            return false unless @game.phase.status.include?('train_obligation')

            entity.floated?
          end

          def buyable_trains(entity)
            trains = super
            return trains unless @game.phase.status.include?('train_obligation')
            return trains if @game.fulfilled_train_obligation.include?(entity.id)

            min = @game.depot.min_depot_train
            trains.select { |t| t == min || t.from_depot? && t.price == min.price }
          end

          def process_buy_train(action)
            super
            if @game.phase.status.include?('train_obligation')
              @game.fulfilled_train_obligation.add(action.entity.id)
            end
          end

          # TODO: Nationals claiming rusted trains for free (openpoints §1.9, §3.7) — deferred
        end
      end
    end
  end
end
