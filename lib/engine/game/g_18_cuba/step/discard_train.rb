# frozen_string_literal: true

require_relative '../../../step/discard_train'

module Engine
  module Game
    module G18Cuba
      module Step
        class DiscardTrain < Engine::Step::DiscardTrain
          def trains(corporation)
            excess = @game.train_limit_overflow(corporation)
            corporation.trains.select { |t| @game.wagon?(t) ? excess[:wagons] : excess[:trains] }
          end
        end
      end
    end
  end
end
