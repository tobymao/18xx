# frozen_string_literal: true

require_relative '../../g_1880/step/buy_train'

module Engine
  module Game
    module G1880Romania
      module Step
        class BuyTrain < G1880::Step::BuyTrain
          def avoid_discarding_final_trains?(train)
            (train.name == '8' && train.index == 1) || %w[8E 2P].include?(train.name) || !discard_trains?
          end
        end
      end
    end
  end
end
