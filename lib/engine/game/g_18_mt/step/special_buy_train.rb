# frozen_string_literal: true

require_relative '../../../step/special_buy_train'
require_relative 'train'

module Engine
  module Game
    module G18MT
      module Step
        class SpecialBuyTrain < Engine::Step::SpecialBuyTrain
          include G18MT::Train

          def actions(entity)
            return [] unless ability(entity)
            return [] unless @round.train_buy_available

            ACTIONS
          end

          def buyable_trains(entity)
            trains = @game.abilities(entity, :train_discount, time: ability_timing)&.trains || []
            super.select { |t| trains.include?(t.name) && t.from_depot? }
          end
        end
      end
    end
  end
end
