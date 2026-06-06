# frozen_string_literal: true

module Engine
  module Game
    module G1835
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def buyable_trains(_entity)
            return super if @game.phase.status.include?('can_buy_trains')

            super.select(&:from_depot?)
          end

          def can_entity_buy_train?(entity)
            entity.corporation? || entity.minor?
          end

          def must_buy_train?(entity)
            return false if entity.minor?

            super
          end
        end
      end
    end
  end
end
