# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1894
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def setup
            super
            @exchanged = false
          end
        end
      end
    end
  end
end
