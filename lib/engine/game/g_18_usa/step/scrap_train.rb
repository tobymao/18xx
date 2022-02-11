# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'scrap_train_module'
module Engine
  module Game
    module G18USA
      module Step
        class ScrapTrain < Engine::Step::Base
          include ScrapTrainModule
          def actions(entity)
            actions = []
            actions << 'scrap_train' if entity == current_entity && entity.corporation? &&
                entity.trains.any? { |t| @game.pullman_train?(t) }
            actions << 'pass' if blocks?
            actions
          end

          def blocks?
            @round.paid_loans[current_entity] && can_scrap_train?(current_entity)
          end

          def description
            'Scrap Pullman'
          end

          def pass_description
            'Skip Scrap Pullman'
          end

          def can_scrap_train?(entity)
            return false unless entity.corporation?
            return false unless entity.owned_by?(current_entity)

            entity.trains.find { |t| @game.pullman_train?(t) }
          end

          def process_scrap_train(action)
            @corporate_action = action
            @game.scrap_train_by_corporation(action, current_entity)
          end
        end
      end
    end
  end
end
