# frozen_string_literal: true

require_relative '../train'

module Engine
  module Step
    module G1836Jr30
      class Train < Train

        def process_buy_train(action)
          # Since the train won't be in the depot after being bougth store the state now.
          add_to_list = action.train.from_depot?
          super
          if add_to_list
            depot_trains_bought = action.train.sym
            pass! unless buyable_trains.reject { |x| x.from_depot? && depot_trains_bought == x.sym }.any?
          end
        end
      end
    end
  end
end
