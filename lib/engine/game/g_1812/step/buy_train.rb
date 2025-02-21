# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/buy_train'
require_relative '../../../step/automatic_loan'

module Engine
  module Game
    module G1812
      module Step
        class BuyTrain < G1867::Step::BuyTrain
          include Engine::Step::AutomaticLoan

          def pass!
            Engine::Step::BuyTrain.instance_method(:pass!).bind_call(self)

            @game.trainless_penalty(current_entity) if current_entity.trains.empty?
          end

          def discountable_trains_allowed?(_entity)
            @game.phase.name.to_i >= 5
          end

          def buy_train_action(action, _entity = nil)
            @depot_train = action.train.from_depot?

            Engine::Step::BuyTrain.instance_method(:buy_train_action).bind_call(self)
          end
        end
      end
    end
  end
end
