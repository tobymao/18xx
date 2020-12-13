# frozen_string_literal: true

require_relative '../buy_train.rb'

module Engine
  module Step
    module G18CO
      class BuyTrain < BuyTrain
        def issuable_shares(entity)
          shares = super

          return [] if available_cash(entity) >= @depot.min_depot_price

          shares
        end
      end
    end
  end
end
