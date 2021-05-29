# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1856
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def must_buy_train?(entity)
            return super if entity != @game.national || @game.national_ever_owned_permanent

            cash = entity.cash
            # Can't use empty because the national may have a permanent train borrowed :(
            has_tradeable_train = entity.trains.any?(&:rusts_on)
            cash > @game.ultimate_train_price || (has_tradeable_train && cash > @game.ultimate_train_trade_in)
          end

          def process_buy_train(action)
            check_spend(action)
            buy_train_action(action)

            @game.national_bought_permanent if action.entity == @game.national && !action.train.rusts_on

            pass! unless can_buy_train?(action.entity)
          end

          def buyable_trains(entity)
            trains = super
            trains.reject!(&:rusts_on) if entity == @game.national
            trains
          end

          def pass!
            if (borrowed_train = @game.borrowed_trains[current_entity])
              @game.log << "#{current_entity.name} returns #{borrowed_train.name}"
              @game.depot.reclaim_train(borrowed_train)
              @game.borrowed_trains[current_entity] = nil
            end
            super
          end
        end
      end
    end
  end
end
