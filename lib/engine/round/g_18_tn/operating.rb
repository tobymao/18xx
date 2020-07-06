# frozen_string_literal: true

require_relative '../operating'

module Engine
  module Round
    module G18TN
      class Operating < Operating
        def initialize(entities, game:, round_num: 1, **opts)
          super
          @depot_trains_bought = []
        end

        def start_operating
          @depot_trains_bought = []
          super
        end

        def buyable_trains
          super.reject { |x| x.from_depot? && @depot_trains_bought.any? && !@game.phase.available?('4') }
        end

        def can_buy_train?
          super && (@depot_trains_bought.empty? || buyable_trains.any?)
        end

        def process_buy_train(action)
          # Since the train won't be in the depot after being bougth store the state now.
          add_to_list = action.train.from_depot?
          super
          @depot_trains_bought << action.train.sym if add_to_list
        end
      end
    end
  end
end
