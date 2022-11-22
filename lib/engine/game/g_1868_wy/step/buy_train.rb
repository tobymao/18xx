# frozen_string_literal: true

require_relative '../../../step/buy_train'
require_relative '../skip_coal_and_oil'
require_relative 'choose_big_boy'

module Engine
  module Game
    module G1868WY
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          include G1868WY::SkipCoalAndOil
          include ChooseBigBoy

          def actions(entity)
            super.concat(choice_actions(entity, cannot_pass: entity.corporation? && must_buy_train?(entity)))
          end

          def process_choose(action)
            process_choose_big_boy(action)
          end

          def process_buy_train(action)
            super
            action.train.remove_variants!
          end
        end
      end
    end
  end
end
