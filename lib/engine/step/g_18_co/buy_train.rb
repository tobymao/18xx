# frozen_string_literal: true

require_relative '../buy_train'

module Engine
  module Step
    module G18CO
      class BuyTrain < BuyTrain
        def issuable_shares(entity)
          return [] if available_cash(entity) >= @depot.min_depot_price

          super
        end

        def process_sell_shares(action)
          @last_share_issued_price = action.bundle.price_per_share if action.entity == current_entity
          super
        end

        def buyable_trains(entity)
          trains = super
          return trains unless @last_share_issued_price&.positive?

          trains.reject { |t| t.owner.corporation? }
        end
      end
    end
  end
end
