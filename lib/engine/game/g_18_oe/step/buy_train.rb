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
            entity.floated? && entity.trains.empty? && (!@game.fulfilled_train_obligation?(entity) || entity.type == :major)
          end

          def buyable_trains(entity)
            trains = super
            return trains unless @game.phase.status.include?('train_obligation')

            if !@game.fulfilled_train_obligation?(entity)
              trains.select { |t| t.name == '2+2' }
            else
              return [] unless @game.non_starter_trains_available?

              trains.reject { |t| t.name == '2+2' }
            end
          end

          def process_buy_train(action)
            super
            @game.fulfill_train_obligation!(action.entity) if action.train.name == '2+2' && action.train.from_depot?
          end

          # TODO: Nationals claiming rusted trains for free (openpoints §1.9, §3.7) — deferred
        end
      end
    end
  end
end
