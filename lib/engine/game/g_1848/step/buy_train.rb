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

            # do emergency loan
            @game.perform_ebuy_loans(entity, remaining) if remaining.positive?

            # company is closing, not buying train
            return if entity.share_price.price.zero?

            super
          end

          def can_entity_buy_train?(entity)
            return false if entity == @game.boe

            super
          end

          def buyable_trains(entity)
            # Cannot buy 2E if one is already owned
            owns_2e = entity.trains.any? { |t| t.name == '2E' }
            return super if !owns_2e && @game.phase.status.include?('can_buy_trains')

            super.reject { |t| t.name == '2E' } if owns_2e
            super.select(&:from_depot?) unless @game.phase.status.include?('can_buy_trains')
          end

          def room?(entity)
            entity.trains.count { |t| t.name != '2E' } < @game.train_limit(entity)
          end

          def spend_minmax(entity, train)
            train_corp_owner = train.owner.owner
            min = train_corp_owner == entity.owner ? 1 : train.price
            max = train_corp_owner == entity.owner ? buying_power(entity) : train.price

            [min, max]
          end
        end
      end
    end
  end
end
