# frozen_string_literal: true

require_relative '../../../step/discard_train'

module Engine
  module Game
    module G1866
      module Step
        class DiscardTrain < Engine::Step::DiscardTrain
          def trains(corporation)
            corporation.trains.reject { |t| t.obsolete || @game.infrastructure_train?(t) }
          end
        end
      end
    end
  end
end
