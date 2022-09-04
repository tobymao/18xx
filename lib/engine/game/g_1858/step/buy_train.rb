# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1858
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return [] if entity.minor?
            return [] if entity != current_entity

            actions = []
            actions << 'buy_train' if can_buy_train?(entity)
            actions << 'scrap_train' unless scrappable_trains(entity).empty?
            actions << 'pass' unless actions.empty?
            actions
          end

          def scrappable_trains(entity)
            entity.trains.select(&:obsolete)
          end

          def scrap_info(_train)
            ''
          end

          def scrap_button_text(_train)
            'Scrap'
          end

          def process_scrap_train(action)
            @log << "#{action.entity.name} discards wounded #{action.train.name} train"
            @game.remove_train(action.train)
          end
        end
      end
    end
  end
end
