# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18Cuba
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def round_state
            # Track which minor corporations have exchanged for narrow gauge trains this OR.
            super.merge(narrow_gauge_exchanged_by: [])
          end

          # Take engine's depot list (already narrowed to the cheapest gauge-matching
          # train), then drop wagons unless the entity may buy one,
          # and narrow to wagons only once the regular-train slots are full.
          def buyable_trains(entity)
            trains = super
            trains.reject! { |t| @game.wagon?(t) } unless can_buy_wagon?(entity)
            return trains unless at_train_limit?(entity)

            trains.select { |t| @game.wagon?(t) }
          end

          # Pure variant filter: aged lock, emergency cheapest, gauge match.
          def buyable_train_variants(train, entity)
            variants = super

            if train.variants.values.any? { |v| v[:event_downgrade_variant] }
              variants = variants.select { |v| v == train.variant }
            end

            if entity.cash < @depot.min_depot_price
              min_price = variants.map { |v| v[:price] }.min
              variants = variants.select { |v| v[:price] == min_price }
            end

            return variants if @game.wagon?(train)

            variants.select { |v| v[:track_type] == @game.gauge_for(entity) }
          end

          # Extend it to allow wagons if the entity is eligible to buy them.
          def room?(entity, _shell = nil)
            super || can_buy_wagon?(entity)
          end

          # Per rule VII.12: wagons bought cross-company must be paid at face value; standard trains stay negotiable.
          def must_buy_at_face_value?(train, entity)
            @game.wagon?(train) || super
          end

          def discountable_trains_allowed?(entity)
            # Minors can only exchange for narrow gauge trains, and only once per OR.
            entity.type == :minor && !@round.narrow_gauge_exchanged_by.include?(entity.id)
          end

          def process_buy_train(action)
            if action.exchange
              raise GameError, "#{action.entity.name} has already exchanged a narrow gauge train this OR" \
                unless discountable_trains_allowed?(action.entity)

              @round.narrow_gauge_exchanged_by << action.entity.id
            end
            super
          end

          def names_of_cheapest_variants(train)
            buyable = train.variants.reject { |_, v| v[:event_downgrade_variant] || v[:price] > train.price }
            return [train.name] if buyable.empty?

            buyable.group_by { |_, v| v[:price] }.min_by { |k, _| k }.last.flat_map(&:first)
          end

          private

          def at_train_limit?(entity)
            @game.num_corp_trains(entity) >= @game.train_limit(entity)
          end

          def can_buy_wagon?(entity)
            entity.type == :major && @game.num_wagons(entity) < @game.train_limit(entity)
          end
        end
      end
    end
  end
end
