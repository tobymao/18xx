# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1862
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          WARRANTY_COST = 50

          def round_state
            super.merge(
              {
                emergency_buy: false,
              }
            )
          end

          def setup
            @round.emergency_buy = false
            super
          end

          def actions(entity)
            return [] if entity != current_entity
            return [] if entity.corporation? && entity.receivership?
            return [] if @game.skip_round[entity]
            return [] unless room?(entity)
            return [] if buyable_trains(entity).empty? && !must_buy_train?(entity)
            return [] if entity.share_price&.type == :close

            actions = []
            actions << 'buy_train' unless buyable_trains(entity).empty?
            actions << 'convert' if !can_buy_depot_train?(entity) && must_buy_train?(entity) && ebuy_choice?(entity)
            actions << 'pass' if !actions.empty? && !(can_buy_depot_train?(entity) && must_buy_train?(entity))

            actions
          end

          def log_pass(entity)
            super unless must_ebuy?(entity)
          end

          def log_skip(entity)
            super if !must_ebuy?(entity) && !@game.skip_round[entity]
          end

          def skip!
            if !@game.skip_round[current_entity] && current_entity.corporation? && current_entity.receivership?
              return receivership_buy(current_entity)
            end

            super
          end

          def pass!
            return ebuy(current_entity) if !@game.skip_round[current_entity] && must_ebuy?(current_entity)

            super
          end

          def must_ebuy?(entity)
            @game.must_buy_train?(entity)
          end

          # corp can afford depot train
          def can_buy_depot_train?(entity)
            entity.cash >= @depot.upcoming.first.price
          end

          def delta_cash(entity)
            @depot.upcoming.first.price - entity.cash
          end

          def can_sell_stock?(entity, delta)
            entity.num_shares_of(entity) * entity.share_price.price >= delta
          end

          def can_refinance?(entity, delta)
            entity.original_par_price.price * 10 >= delta
          end

          def ebuy_choice?(entity)
            delta = delta_cash(entity)
            can_sell_stock?(entity, delta) && can_refinance?(entity, delta)
          end

          def pass_description
            if @acted
              'Done (Trains)'
            elsif must_ebuy?(current_entity) && can_sell_stock?(current_entity, (delta = delta_cash(current_entity)))
              'Sell Stock for Forced Purchase'
            elsif must_ebuy?(current_entity) && can_refinance?(current_entity, delta)
              'Refinance for Forced Purchase'
            elsif must_ebuy?(current_entity)
              'Enter Bankruptcy (Forced Purchase)'
            else
              'Skip (Trains)'
            end
          end

          def convert_text(_entity)
            'Refinance for Forced Purchase'
          end

          def ebuy(entity)
            delta = delta_cash(entity)
            @log << "#{entity.name} must buy a train and is short #{@game.format_currency(delta)}"
            @round.emergency_buy = true
            if can_sell_stock?(entity, delta)
              @log << "#{entity.name} will sell treasury shares"
              @game.raise_money!(entity, delta)
              receivership_buy(entity) if entity.receivership?
              @round.clear_cache!
            elsif can_refinance?(entity, delta)
              @log << "#{entity.name} will refinance"
              @game.refinance!(entity)
              receivership_buy(entity) if entity.receivership?
              @round.clear_cache!
            else
              @log << "#{entity.name} will enter bankruptcy"
              @game.enter_bankruptcy!(entity)
              @passed = true
            end
          end

          def voluntary_refinance(entity)
            delta = delta_cash(entity)
            raise GameError, 'Logic error: cannot refinance' unless can_refinance?(entity, delta)

            @log << "#{entity.name} must buy a train and is short #{@game.format_currency(delta)}"
            @round.emergency_buy = true
            @log << "#{entity.name} will refinance"
            @game.refinance!(entity)
          end

          def receivership_buy(entity)
            @passed = true
            if (buy_type = receivership_train(entity))
              @log << "#{entity.name} is in Receivership and must buy a train"
              train = @depot.depot_trains.first
              variant_name = train.variants.keys.find { |n| n != train.sym && @game.train_type_by_name(n) == buy_type }

              buy_train_action(
                Engine::Action::BuyTrain.new(
                  entity,
                  train: train,
                  price: train.price, # all variants have the same price as the base train
                  variant: variant_name,
                  shell: nil,
                  slots: nil,
                  warranties: 0,
                )
              )
            elsif entity.trains.empty?
              @log << "#{entity.name} is in Receivership and cannot buy a train"
              @game.enter_bankruptcy!(entity)
            else
              log_skip(entity)
            end
          end

          def receivership_train(entity)
            return nil if entity.cash < @depot.min_depot_price

            permit_list = @game.permits[entity].sort_by(&:to_s) # order: express, freight, local
            permit_list.each do |permit_type|
              return permit_type if room_for_type?(entity, permit_type)
            end
            nil
          end

          def room?(entity, _shell = nil)
            if @game.phase.available?('G')
              entity.trains.size < @game.train_limit(entity)
            else
              entity.trains.empty? || room_for_any_type?(entity)
            end
          end

          def room_for_any_type?(entity)
            trains = entity.trains.group_by { |t| @game.train_type(t) }
            trains.keys.size < 3 || trains.values.any? { |v| v.size < @game.train_limit_by_type(entity) }
          end

          def room_for_type?(entity, type)
            trains = entity.trains.group_by { |t| @game.train_type(t) }
            (trains[type]&.size || 0) < @game.train_limit_by_type(entity)
          end

          def buyable_trains(entity)
            depot_trains = @depot.depot_trains.reject { |t| entity.cash < t.price }
            other_trains = @game.lner ? [] : @depot.other_trains(entity)

            other_trains.reject! { |t| entity.cash < @game.used_train_price(t) }
            other_trains.reject! { |t| t.owner.receivership? }
            other_trains.select! { |t| room_for_type?(entity, @game.train_type(t)) }

            @round.emergency_buy ? depot_trains : depot_trains + other_trains
          end

          def buyable_train_variants(train, entity)
            return [] unless buyable_trains(entity).find(train)

            variants = train.variants.values
            return variants if train.owned_by_corporation?
            return [] unless buyable_trains(entity).any? { |bt| bt.variants[bt.name] }

            variants.reject! { |v| v[:name] == train.sym }
            variants.select! { |v| room_for_type?(entity, @game.train_type_by_name(v[:name])) }
            variants
          end

          def check_spend(action)
            warranties = action.warranties || 0
            return unless action.entity.cash < action.price + (warranties * WARRANTY_COST)

            raise GameError, "#{action.entity.name} cannot afford warranty cost of "\
                             "#{@game.format_currency(warranties * WARRANTY_COST)} in addition to train"
          end

          def buy_train_action(action)
            @round.emergency_buy = false
            entity = action.entity
            train = action.train
            warranties = action.warranties || 0
            if warranties.positive?
              if warranties > warranty_limit(train)
                raise GameError "Can only purchase #{warranty_limit(train)} warranties for train"
              end

              entity.spend(warranties * WARRANTY_COST, @game.bank)
              suffix = warranties > 1 ? 'ies' : 'y'
              @log << "#{entity.name} pays #{@game.format_currency(warranties * WARRANTY_COST)} "\
                      "for #{warranties} warrant#{suffix}"
            end

            super

            warranties.times { train.name = train.name + '*' }
          end

          def process_convert(action)
            voluntary_refinance(action.entity)
          end

          def president_may_contribute?(_entity, _shell = nil)
            false
          end

          def fixed_price(train)
            @game.used_train_price(train)
          end

          def warranty_text
            train = @depot.depot_trains.first
            if train.sym.include?('A') || train.sym.include?('D')
              'Additional Warranties (each)'
            else
              'Warranties (each)'
            end
          end

          def warranty_max
            warranty_limit(@depot.depot_trains.first)
          end

          def warranty_limit(train)
            if train.sym.include?('A') || train.sym.include?('D')
              2
            else
              3
            end
          end

          def warranty_cost
            @game.format_currency(WARRANTY_COST)
          end

          def ebuy_president_can_contribute?(_corporation)
            false
          end
        end
      end
    end
  end
end
