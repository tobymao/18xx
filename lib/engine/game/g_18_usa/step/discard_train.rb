# frozen_string_literal: true

require_relative '../../../step/discard_train'

module Engine
  module Game
    module G18USA
      module Step
        class DiscardTrain < Engine::Step::DiscardTrain
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

          def scrappable_trains(entity)
            entity.trains.select { |t| t.name == 'P' }
          end

          def scrap_info(_)
            @game.scrap_info
          end

          def scrap_button_text(_)
            @game.scrap_button_text
          end

          def process_scrap_train(action)
            @corporate_action = action
            @game.scrap_train_by_corporation(action, current_entity)
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
