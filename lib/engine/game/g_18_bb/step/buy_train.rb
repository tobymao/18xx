# frozen_string_literal: true

require_relative '../../g_1846/step/buy_train'

module Engine
  module Game
    module G18BB
      module Step
        class BuyTrain < G1846::Step::BuyTrain
          def buyable_train_variants(train, entity)
            variants = super
            variants.reject! { |v| v[:name] == '2g' } unless can_buy_2g?(entity)
            variants
          end

          def can_buy_2g?(entity)
            @game.green_2_corps.include?(entity) && entity.trains.none? { |t| t.name == '2g' }
          end

          def room?(entity)
            return super unless @game.phase.tiles.include?(:brown)

            entity.trains.count { |t| !t.obsolete && t.name != '2g' } < @game.train_limit(entity)
          end
        end
      end
    end
  end
end
