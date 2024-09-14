# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1837
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def buyable_train_variants(train, entity)
            variants = super
            variants.select! { |t| @game.freight_train?(t[:name]) } if entity.type == :coal
            variants
          end

          def other_trains(entity)
            trains = super
            trains.select! { |t| @game.freight_train?(t.name) } if entity.type == :coal
            trains
          end

          def can_entity_buy_train?(_entity)
            true
          end
        end
      end
    end
  end
end
