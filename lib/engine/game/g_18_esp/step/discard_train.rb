# frozen_string_literal: true

require_relative '../../../step/discard_train'

module Engine
  module Game
    module G18ESP
      module Step
        class DiscardTrain < Engine::Step::DiscardTrain
          def trains(corporation)
            # 2 train from P3 can not be discarded
            corporation.trains.reject { |t| t.id == @game.class::P3_TRAIN_ID }
          end
        end
      end
    end
  end
end
