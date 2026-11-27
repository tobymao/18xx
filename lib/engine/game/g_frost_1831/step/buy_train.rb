# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module GFrost1831
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def ebuy_president_can_contribute?(_corporation)
            false
          end

          def president_may_contribute?(_entity, _shell = nil)
            false
          end
        end
      end
    end
  end
end
