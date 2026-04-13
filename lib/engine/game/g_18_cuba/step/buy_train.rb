# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18Cuba
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def round_state
            # Track which minor corporations have exchanged for narrow gauge trains this OR
            super.merge({ narrow_gauge_exchanged_by: [] })
          end

          def buyable_trains(entity)
            trains = super

            if entity.type == :minor
              trains.select { |t| t.track_type == :narrow }
            else
              trains.select { |t| t.track_type == :broad }
            end
          end

          def buyable_train_variants(train, entity)
            variants = super
            # 4n trains can downgrade to 4-1n.
            # Only the currently active variant (based on train.name) is buyable.
            return variants.select { |variant| variant[:name] == train.name } if train.variants.key?('4-1n')

            variants
          end

          def discountable_trains_allowed?(entity)
            # Minors can only exchange for narrow gauge trains, and can only do so once per OR.
            entity.type == :minor && !@round.narrow_gauge_exchanged_by.include?(entity.id)
          end

          def process_buy_train(action)
            # If the player is exchanging a narrow gauge train, ensure they haven't already done so this OR,
            # and track that they have.
            if action.exchange
              raise GameError, "#{action.entity.name} has already exchanged a narrow gauge train this OR" \
                unless discountable_trains_allowed?(action.entity)

              @round.narrow_gauge_exchanged_by << action.entity.id
            end
            super
          end
        end
      end
    end
  end
end
