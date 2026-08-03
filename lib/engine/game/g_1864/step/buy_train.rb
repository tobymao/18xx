# frozen_string_literal: true

require_relative 'skip_for_national'
require_relative '../../g_1867/step/buy_train'

module Engine
  module Game
    module G1864
      module Step
        class BuyTrain < G1867::Step::BuyTrain
          include SkipForNational
        end
      end
    end
  end
end
