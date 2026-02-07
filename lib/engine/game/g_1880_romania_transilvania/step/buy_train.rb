# frozen_string_literal: true

require_relative '../../g_1880/step/buy_train'

module Engine
  module Game
    module G1880RomaniaTransilvania
      module Step
        class BuyTrain < G1880::Step::BuyTrain
          def avoid_discarding_all_trains?(train_name, train_index)
            %w[8 2P].include?(train_name) || !discard_trains?
          end
        end
      end
    end
  end
end
