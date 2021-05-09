# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1840
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return [] if entity.minor?
            return [] if entity != current_entity
            return [] if entity.type == :city
            return %w[buy_train pass] if can_buy_train?(entity)

            []
          end

          def buyable_trains(entity)
            super
          end

          def buyable_train_variants(train, entity)
            base = super
            base.select { |item| @game.available_trains.include?(item[:name]) }
          end
        end
      end
    end
  end
end
