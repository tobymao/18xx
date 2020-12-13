# frozen_string_literal: true

require_relative '../buy_train.rb'

module Engine
  module Step
    module G18CO
      class BuyTrain < BuyTrain
        def issuable_shares
          # seems likes this should be generic?
          return [] if room?(current_entity) && available_cash(current_entity) >= @depot.min_depot_price

          @game.emergency_issuable_bundles(current_entity)
        end
      end
    end
  end
end
