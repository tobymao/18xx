# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1848
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def buy_train_action(action, entity = nil, borrow_from: nil)
            entity ||= action.entity
            price = action.price
            remaining = price - buying_power(entity)

            if remaining.positive? && !@game.round.actions_for(entity).include?('pass')
              # do emergency loan
              if @game.round.actions_for(entity).include?('take_loan')
                raise GameError,
                      "#{entity.name} can take a regular loan, prior to performing Compulsory Train Purchase"
              end

              @game.perform_ebuy_loans(entity, remaining)
            end
            return if entity.share_price.price.zero? # company is closing, not buying train

            super
          end

          def can_entity_buy_train?(entity)
            return false if entity == @game.boe

            super
          end

          def buyable_trains(entity)
            # Cannot buy 2E if one is already owned
            trains_to_buy = super
            trains_to_buy = trains_to_buy.select(&:from_depot?) unless @game.can_buy_trains
            trains_to_buy = trains_to_buy.reject { |t| t.name == '2E' } if owns_2e?(entity)
            fix_2e_issue(entity, trains_to_buy)
          end

          def owns_2e?(entity)
            entity.trains.any? { |t| t.name == '2E' }
          end

          def fix_2e_issue(entity, trains_to_buy)
            # entity can buy the  ghan train cheaper. Add it to list of buyable trains if it has enough cash after discount.
            entity_abilities = @game.abilities(entity, :train_discount, time: ability_timing)
            if entity_abilities
              ghan = @depot.trains.find { |t| t.name == '2E' }
              if @game.phase.available?(ghan.available_on) && !trains_to_buy.include?(ghan) &&
                ghan.price - entity_abilities.discount <= entity.cash
                trains_to_buy << ghan
              end
            end
            trains_to_buy
          end

          def room?(entity)
            entity.trains.count { |t| t.name != '2E' } < @game.train_limit(entity)
          end

          def spend_minmax(entity, train)
            return [1, buying_power(entity)] if train.owner.owner == entity.owner

            [train.price, train.price]
          end
        end
      end
    end
  end
end
