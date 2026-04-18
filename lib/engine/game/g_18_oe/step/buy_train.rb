# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18OE
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def can_entity_buy_train?(entity)
            entity.corporation? && entity.type != :minor
          end

          def buyable_trains(entity)
            trains = super
            return trains.select { |t| t.name == '2+2' } if entity.trains.empty? && @game.phase.name.to_i < 4

            trains
          end

          # TODO: Nationals claiming rusted trains for free (openpoints §1.9, §3.7) — deferred
        end
      end
    end
  end
end
