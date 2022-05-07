# frozen_string_literal: true

require_relative '../../g_1822/step/discard_train'

module Engine
  module Game
    module G1822MX
      module Step
        class DiscardTrain < Engine::Game::G1822::Step::DiscardTrain
          def trains(corporation)
            if @game.extra_train_pullman_count(corporation) > 1
              return corporation.trains.select { |t| @game.extra_train_pullman?(t) }
            end

            super
          end
        end
      end
    end
  end
end
