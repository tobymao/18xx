# frozen_string_literal: true

require_relative '../../g_1880/step/buy_train'

module Engine
  module Game
    module G1880Romania
      module Step
        class BuyTrain < G1880::Step::BuyTrain
          def actions(entity)
            actions = super
            return actions if entity != current_entity
            return %w[pass] if actions.empty? && banater_enables_purchase?(entity)

            actions
          end

          def avoid_discarding_final_trains?(train)
            (train.name == '8' && train.index == 1) || %w[8E 2R].include?(train.name) || !discard_trains?
          end

          private

          def banater_enables_purchase?(entity)
            return false unless entity.corporation?

            banater = @game.banater
            return false if banater&.closed? || banater&.owner != entity.owner

            price = @game.depot.min_depot_price
            entity.cash < price && entity.cash + 40 >= price && room?(entity)
          end
        end
      end
    end
  end
end
