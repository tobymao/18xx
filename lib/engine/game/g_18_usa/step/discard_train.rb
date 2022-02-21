# frozen_string_literal: true

require_relative '../../../step/discard_train'
require_relative 'scrap_train_module'
module Engine
  module Game
    module G18USA
      module Step
        class DiscardTrain < Engine::Step::DiscardTrain
          include ScrapTrainModule
          def actions(entity)
            actions = super
            actions << 'scrap_train' if can_scrap_train?(entity)
            actions
          end

          def trains(corporation)
            return super unless corporation.trains.count { |t| @game.pullman_train?(t) } > 1

            corporation.trains.select { |t| @game.pullman_train?(t) }
          end
        end
      end
    end
  end
end
