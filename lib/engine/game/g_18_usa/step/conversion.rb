# frozen_string_literal: true

require_relative '../../g_1817/step/conversion'
require_relative 'scrap_train_module'
module Engine
  module Game
    module G18USA
      module Step
        class Conversion < G1817::Step::Conversion
          include ScrapTrainModule
          def actions(entity)
            actions = super
            actions << 'scrap_train' if entity.corporation? && entity.trains.any? { |t| @game.pullman_train?(t) } &&
                !actions.empty?
            actions
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
