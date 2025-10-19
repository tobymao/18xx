# frozen_string_literal: true

require_relative '../../../step/buy_train'
require_relative '../../../step/automatic_loan'

module Engine
  module Game
    module G1844
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def buyable_train_variants(train, entity)
            variants = super
            variants.select! { |t| @game.hex_train_name?(t[:name]) } if entity.type == :regional
            variants
          end

          def other_trains(entity)
            trains = super
            trains.select! { |t| @game.hex_train_name?(t.name) } if entity.type == :regional
            trains
          end

          def spend_minmax(entity, train)
            return [train.price, train.price] if [train.owner, entity].include?(@game.sbb) ||
                                                  (train.owner&.corporation? && train.owner.owner != entity.owner)

            super
          end

          def must_take_player_loan?(entity)
            @game.depot.min_depot_price > (entity.cash + entity.owner.cash)
          end
        end
      end
    end
  end
end
