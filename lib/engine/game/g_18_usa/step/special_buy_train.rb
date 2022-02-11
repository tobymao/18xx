# frozen_string_literal: true

require_relative '../../../step/special_buy_train'
require_relative 'scrap_train_module'
module Engine
  module Game
    module G18USA
      module Step
        class SpecialBuyTrain < Engine::Step::SpecialBuyTrain
          include ScrapTrainModule
          def must_buy_train?(_entity)
            false
          end

          def buyable_trains(entity)
            trains = @game.abilities(entity, :train_discount, time: ability_timing)&.trains || []
            super.select { |t| trains.include?(t.name) && t.from_depot? }
          end

          def process_buy_train(action)
            close_company = !@round.active_step.respond_to?(:buyable_trains)
            super
            return unless close_company

            @log << "#{action.entity.name} closes"
            action.entity.close!
          end
        end
      end
    end
  end
end
