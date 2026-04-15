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
            track_type = entity.type == :minor ? :narrow : :broad

            if must_buy_train?(entity)
              # Emergency buy: only depot/discard trains allowed (not from other companies),
              # and only the cheapest of the correct track type.
              available = @depot.depot_trains.select { |t| t.track_type == track_type }
              cheapest_price = available.map { |t| t.price }.min
              result = cheapest_price ? available.select { |t| t.price == cheapest_price } : []
              return result
            end

            # Normal buy: filter by track type.
            return super.select { |t| t.track_type == track_type }
          end

          def buyable_train_variants(train, entity)
            variants = super
            # 4n trains can downgrade to 4-1n.
            # Only the currently active variant (based on train.name) is buyable.
            return variants.select { |variant| variant[:name] == train.name } if train.variants.key?('4-1n')

            # During emergency buy, only the cheapest variant is allowed.
            if must_buy_train?(entity)
              min_price = variants.map { |v| v[:price] }.min
              return variants.select { |v| v[:price] == min_price }
            end

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
