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
            track_type = track_type_for(entity)

            if must_buy_train?(entity)
              # Emergency buy: only depot/discard trains allowed (not from other companies),
              # wagons excluded, only the cheapest of the correct track type.
              sources = @depot.depot_trains + @depot.discarded
              available = sources.select { |t| t.track_type == track_type && !@game.wagon?(t) }
              return [] if available.empty?

              cheapest_price = available.map(&:price).min
              return available.select { |t| t.price == cheapest_price }
            end

            # Normal buy: minors get narrow trains only; majors get broad trains and wagons.
            # Wagons are only buyable if the corporation has a free wagon slot.
            # Regular trains are only buyable if the train limit is not yet reached.
            case entity.type
            when :minor
              super.select { |t| t.track_type == :narrow }
            when :major
              trains_full = @game.num_corp_trains(entity) >= @game.train_limit(entity)
              wagon_slot_available = @game.num_wagons(entity) < @game.train_limit(entity)
              super.select do |t|
                @game.wagon?(t) ? wagon_slot_available : (!trains_full && t.track_type == :broad)
              end
            else
              raise GameError, "Unexpected entity type: #{entity.type}"
            end
          end

          def check_for_cheapest_train(train)
            return if @game.wagon?(train)

            track_type = track_type_for(current_entity)
            candidates = (@depot.depot_trains + @depot.discarded)
                           .reject { |t| @game.wagon?(t) || t.track_type != track_type }
            cheapest = candidates.min_by(&:price)
            return super unless cheapest

            return if names_of_cheapest_variants(cheapest).include?(train.name)

            raise GameError, "Cannot purchase #{train.name} train: cheaper train available (#{cheapest.name})"
          end

          def needed_cash(entity)
            candidates = (@depot.depot_trains + @depot.discarded)
                           .select { |t| t.track_type == track_type_for(entity) && !@game.wagon?(t) }
            candidates.map(&:price).min || 0
          end

          def ebuy_president_can_contribute?(corporation)
            return false unless corporation.cash < needed_cash(corporation)

            !must_issue_before_ebuy?(corporation)
          end

          def room?(entity, _shell = nil)
            return super unless entity.type == :major

            # True if either a regular train slot or a wagon slot is open;
            # buyable_trains filters which type the player can actually buy.
            @game.num_corp_trains(entity) < @game.train_limit(entity) ||
              @game.num_wagons(entity) < @game.train_limit(entity)
          end

          def buyable_train_variants(train, entity)
            variants = super
            # Aged trains (e.g. 4-1n) have only one player-buyable variant; the emergency-buy branch below
            # is bypassed in that case.
            return variants.select { |v| v == train.variant } if train.variants.values.any? { |v| v[:event_downgrade_variant] }

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

          def names_of_cheapest_variants(train)
            buyable = train.variants.reject { |_, v| v[:event_downgrade_variant] || v[:price] > train.price }
            return [train.name] if buyable.empty?

            buyable.group_by { |_, v| v[:price] }.min_by { |k, _| k }.last.flat_map(&:first)
          end

          private

          def track_type_for(entity)
            corp = entity.respond_to?(:type) ? entity : @current_entity
            corp.type == :minor ? :narrow : :broad
          end
        end
      end
    end
  end
end
