# frozen_string_literal: true

require_relative '../../g_1822/step/discard_train'

module Engine
  module Game
    module G1822CA
      module Step
        class DiscardTrain < G1822::Step::DiscardTrain
          def trains(corporation)
            return corporation.trains.select { |t| @game.grain_train?(t) } if @game.grain_train_count(corporation) > 1

            super
          end
        end
      end
    end
  end
end
