# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18Uruguay
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def description
            'Buy Trains'
          end

          def pass_description
            if buy_ships?(current_entity)
              'Skip (Ships)'
            else
              super
            end
          end

          def log_skip(entity)
            return if entity.minor?

            super
          end

          def buy_ships?(entity)
            !entity.abilities.find { |ability| ability.type == :Ship }.nil?
          end

          def actions(entity)
            return %w[sell_shares] if entity == current_entity.owner
            return [] if entity != current_entity
            return [] unless entity.corporation?

            actions = %w[buy_train]
            actions << 'take_loan' if may_take_loan?(entity)
            actions << 'pass' unless must_buy_train?(entity)
            actions
          end

          def may_take_loan?(entity)
            return false if entity == @game.rptla || @game.nationalized?
            return true if @game.can_take_loan?(entity) && !@round.loan_taken
            return false unless must_buy_train?(entity)

            must_take_loan?(entity)
          end

          def process_take_loan(action)
            entity = action.entity
            @game.take_loan(entity, action.loan)
            @round.loan_taken = true
          end

          def cheapest_train_price(corporation)
            trains = buyable_trains(corporation).select(&:from_depot?)
            train = trains.min_by(&:price)
            price = train.price
            if buy_ships?(corporation)
              variant = train.variants.values.filter! { |v| v[:name].include?('Ship') }
              price = variant[0]['price'] if !variant.nil? && !variant.size.zero?
            end
            price
          end

          def must_take_loan?(corporation)
            return false if corporation == @game.rptla || @game.nationalized?

            price = cheapest_train_price(corporation)
            @game.buying_power(corporation) < price
          end

          def ebuy_president_can_contribute?(corporation)
            return true if corporation == @game.rptla
            return false unless @game.nationalized?

            super
          end

          def president_may_contribute?(corporation, _shell = nil)
            if corporation == @game.rptla && must_buy_train?(corporation) && ebuy_president_can_contribute?(corporation)
              return true
            end
            return true if must_buy_train?(corporation) && ebuy_president_can_contribute?(corporation)

            false
          end

          def can_issue?(_entity)
            false
          end

          def buy_train_action(action, entity = nil, borrow_from: nil)
            entity ||= action.entity
            price = action.price
            remaining = price - buying_power(entity)
            ebuy = must_buy_train?(entity) && remaining.positive? && entity != @game.rptla
            @game.perform_ebuy_loans(entity, remaining) if ebuy && !@game.nationalized?
            @round.loan_taken = true if ebuy
            @game.close_rptla_private! if entity == @game.rptla && action.train.name != '2'

            super
          end

          def ship_variant?(train)
            train.variants.values.count { |v| v[:name].include?('Ship') }.positive?
          end

          def names_of_cheapest_variants(train)
            train.variants.group_by { |_, v| v[:price] }.min_by { |k, _| k }.last.flat_map(&:first)
          end

          def check_for_cheapest_train(train)
            return super unless current_entity == @game.rptla

            cheapest = buyable_trains(current_entity).min_by(&:price)
            cheapest_names = names_of_cheapest_variants(cheapest)
            raise GameError, "Cannot purchase #{train.name} train: cheaper train available (#{cheapest_names.first})" if
              !cheapest_names.include?(train.name) &&
              @game.class::EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST &&
              (!@game.class::EBUY_OTHER_VALUE || train.from_depot?)
          end

          def buyable_ships(_entity)
            depot_trains = @depot.depot_trains
            depot_trains = depot_trains.filter { |train| ship_variant?(train) }
            depot_trains.reject { |train| train.name == '7' }
          end

          def buyable_trains_others(trains)
            return trains.select { |train| train.owner == @game.depot } if current_entity.cash.zero?

            trains.reject { |train| train.name == '7' }
          end

          def buyable_trains(entity)
            return buyable_trains_others(super) unless entity == @game.rptla
            return buyable_ships(entity) if entity == @game.rptla
          end

          def buyable_train_variants(train, entity)
            variants = super
            variants = if buy_ships?(entity)
                         variants.filter { |v| v[:name].include?('Ship') }
                       else
                         variants.reject { |v| v[:name].include?('Ship') }
                       end
            return {} unless variants

            variants
          end

          def must_buy_at_face_value?(train, corporation)
            return true if corporation == @game.fce || train.owner == @game.fce

            super
          end
        end
      end
    end
  end
end
