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
            # During 2+2 reservation window: unfulfilled floated entities must buy
            if @game.phase.status.include?('train_obligation')
              return false if @game.fulfilled_train_obligation?(entity)

              return entity.floated?
            end

            # Only majors must own a train outside the obligation window (§11.6); insolvency: §3.2 TBD
            entity.floated? && entity.trains.empty? && entity.type == :major
          end

          def buyable_trains(entity)
            trains = super
            return trains unless @game.phase.status.include?('train_obligation')

            if !@game.fulfilled_train_obligation?(entity)
              trains.select { |t| t.name == '2+2' }
            else
              # Rules 8.3 & 11.6: level 3+ requires Major Phase AND OR1 to have ended
              return [] if !@game.major_phase? || !@game.first_or_done

              trains.reject { |t| t.name == '2+2' }
            end
          end

          def process_buy_train(action)
            super
            @game.fulfill_train_obligation(action.entity) if action.train.name == '2+2' && action.train.from_depot?
          end

          # TODO: Nationals claiming rusted trains for free (openpoints §1.9, §3.7) — deferred
        end
      end
    end
  end
end
